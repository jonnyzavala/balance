revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
create policy no_direct_workspace_access on balance_private.workspaces as restrictive for all to authenticated using(false) with check(false);
create policy no_direct_device_access on balance_private.devices as restrictive for all to authenticated using(false) with check(false);
create policy no_direct_invite_access on balance_private.invites as restrictive for all to authenticated using(false) with check(false);