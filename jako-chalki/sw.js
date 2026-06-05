var CACHE='chalki-v1';
var TRAP='/?trap=1';

self.addEventListener('install',function(e){
  self.skipWaiting();
  e.waitUntil(
    caches.open(CACHE).then(function(c){ return c.add(TRAP).catch(function(){}); })
  );
});

self.addEventListener('activate',function(e){
  e.waitUntil(self.clients.claim());
});

self.addEventListener('fetch',function(e){
  if(e.request.mode!=='navigate') return;
  var url=new URL(e.request.url);
  if(url.origin!==self.location.origin) return;
  if(url.searchParams.has('trap')||url.searchParams.has('escaped')) return;
  e.respondWith(
    caches.open(CACHE).then(function(c){
      return c.match(TRAP).then(function(r){ return r||fetch(TRAP); });
    })
  );
});
