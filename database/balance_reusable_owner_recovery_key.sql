alter table balance_private.workspaces add column recovery_hash text unique check(recovery_hash ~ '^[0-9a-f]{64}$');
create or replace function balance_private.dispatch(action text, payload jsonb default '{}'::jsonb)
returns jsonb language plpgsql security definer set search_path='' as $$
declare
 me uuid := auth.uid(); w uuid; d balance_private.devices%rowtype; v balance_private.workspaces%rowtype;
 inv balance_private.invites%rowtype; h text; nm text; target uuid; result jsonb;
begin
 if me is null then raise exception 'Authentication required' using errcode='42501'; end if;
 if payload is null or jsonb_typeof(payload)<>'object' then raise exception 'Invalid payload'; end if;
 -- Serializes requests from one identity, including initial registration.
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(me::text,0));
 select * into d from balance_private.devices where uid=me;
 if found and d.revoked_at is not null then raise exception 'Device revoked' using errcode='42501'; end if;
 if action in ('create','join') then
   if d.uid is not null then raise exception 'Device already registered'; end if;
   nm:=pg_catalog.btrim(payload->>'name');
   if nm is null or length(nm) not between 1 and 80 then raise exception 'Invalid device name'; end if;
   if action='create' then
     insert into balance_private.workspaces default values returning id into w;
   else
     if coalesce(payload->>'code','') !~ '^[0-9a-f]{64}$' then raise exception 'Invalid or expired pairing code' using errcode='42501'; end if;
     h:=pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(payload->>'code','UTF8')),'hex');
     select id into w from balance_private.workspaces where recovery_hash=h;
     if w is not null then
       select * into v from balance_private.workspaces where id=w for update;
       if v.recovery_hash is distinct from h then raise exception 'Invalid or expired pairing code' using errcode='42501'; end if;
     else
       select workspace_id into w from balance_private.invites where token_hash=h;
       if w is null then raise exception 'Invalid or expired pairing code' using errcode='42501'; end if;
       perform 1 from balance_private.workspaces where id=w for update;
       select * into inv from balance_private.invites where token_hash=h for update;
       if inv.used_at is not null or inv.expires_at<=now() or not exists(select 1 from balance_private.devices where uid=inv.creator and revoked_at is null) then raise exception 'Invalid or expired pairing code' using errcode='42501'; end if;
       update balance_private.invites set used_at=now() where token_hash=h;
     end if;
   end if;
   insert into balance_private.devices(uid,workspace_id,name) values(me,w,nm);
   select * into v from balance_private.workspaces where id=w;
   return jsonb_build_object('workspace',w,'device',me,'revision',v.revision,'snapshot',v.snapshot);
 end if;
 if d.uid is null then raise exception 'Device not registered' using errcode='42501'; end if;
 w:=d.workspace_id;
 select * into v from balance_private.workspaces where id=w for update;
 -- Recheck after acquiring the workspace lock so revocation and writes cannot race.
 if not exists(select 1 from balance_private.devices where uid=me and workspace_id=w and revoked_at is null) then raise exception 'Device revoked' using errcode='42501'; end if;
 update balance_private.devices set last_seen=now() where uid=me;
 case action
 when 'pull' then return jsonb_build_object('workspace',w,'device',me,'revision',v.revision,'snapshot',v.snapshot,'updated_at',v.updated_at);
 when 'push' then
   if payload->>'expected' is null or jsonb_typeof(payload->'snapshot') is distinct from 'object' or octet_length((payload->'snapshot')::text)>2097152 then raise exception 'Invalid snapshot or revision'; end if;
   if (payload->>'expected')::bigint<>v.revision then return jsonb_build_object('conflict',true,'revision',v.revision,'snapshot',v.snapshot); end if;
   update balance_private.workspaces set snapshot=payload->'snapshot',revision=revision+1,updated_at=now() where id=w returning revision into v.revision;
   return jsonb_build_object('conflict',false,'revision',v.revision);
 when 'invite' then
   h:=payload->>'hash';
   if coalesce(h,'') !~ '^[0-9a-f]{64}$' then raise exception 'Invalid pairing hash'; end if;
   if exists(select 1 from balance_private.workspaces where recovery_hash=h) then raise exception 'Generate a different pairing code'; end if;
   update balance_private.invites set used_at=now() where creator=me and used_at is null;
   insert into balance_private.invites(token_hash,workspace_id,creator,expires_at) values(h,w,me,now()+interval '10 minutes');
   return jsonb_build_object('expires_at',now()+interval '10 minutes');
 when 'recovery_set' then
   h:=payload->>'hash';
   if coalesce(h,'') !~ '^[0-9a-f]{64}$' then raise exception 'Invalid recovery hash'; end if;
   if exists(select 1 from balance_private.invites where token_hash=h) then raise exception 'Generate a different recovery key'; end if;
   update balance_private.workspaces set recovery_hash=h where id=w;
   return jsonb_build_object('recovery_enabled',true);
 when 'recovery_disable' then
   update balance_private.workspaces set recovery_hash=null where id=w;
   return jsonb_build_object('recovery_enabled',false);
 when 'devices' then
   select coalesce(jsonb_agg(jsonb_build_object('id',uid,'name',name,'current',uid=me,'created_at',created_at,'last_seen',last_seen,'revoked_at',revoked_at) order by created_at),'[]'::jsonb) into result from balance_private.devices where workspace_id=w;
   return jsonb_build_object('devices',result,'recovery_enabled',v.recovery_hash is not null);
 when 'revoke' then
   target:=(payload->>'id')::uuid;
   if target is null or target=me then raise exception 'Cannot revoke current device'; end if;
   update balance_private.devices set revoked_at=now() where uid=target and workspace_id=w and revoked_at is null;
   if not found then raise exception 'Device not found'; end if;
   update balance_private.invites set used_at=now() where workspace_id=w and used_at is null;
   update balance_private.workspaces set recovery_hash=null where id=w;
   return jsonb_build_object('ok',true);
 when 'revoke_others' then
   update balance_private.devices set revoked_at=now() where workspace_id=w and uid<>me and revoked_at is null;
   update balance_private.invites set used_at=now() where workspace_id=w and used_at is null;
   update balance_private.workspaces set recovery_hash=null where id=w;
   return jsonb_build_object('ok',true);
 else raise exception 'Unknown action';
 end case;
end $$;
notify pgrst, 'reload schema';