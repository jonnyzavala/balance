/* Balance local app shell. Never cache API calls or user records. */
const CACHE='balance-shell-v0.6.1';
const FILES=['./','./index.html','./icon.svg','./favicon-32.png','./apple-touch-icon.png','./icon-192.png','./icon-512.png','./manifest.webmanifest'];
const allowed=new Set(FILES.map(path=>new URL(path,self.registration.scope).href));
self.addEventListener('install',event=>{
  event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(FILES)).then(()=>self.skipWaiting()));
});
self.addEventListener('activate',event=>{
  event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('balance-shell-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch',event=>{
  const request=event.request;
  if(request.method!=='GET')return;
  const url=new URL(request.url);
  if(url.origin!==self.location.origin)return;
  const shellURL=url.origin+url.pathname;
  if(!allowed.has(shellURL))return;
  event.respondWith((async()=>{
    const cache=await caches.open(CACHE);
    try {
      const response=await fetch(request);
      if(response.ok){await cache.put(shellURL,response.clone());return response}
      return await cache.match(shellURL)||response;
    } catch(error) {
      const stored=await cache.match(shellURL);
      if(stored)return stored;
      if(request.mode==='navigate')return await cache.match(new URL('./index.html',self.registration.scope).href)||Response.error();
      return Response.error();
    }
  })());
});
