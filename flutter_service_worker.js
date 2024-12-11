'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"main.dart.js": "ffe0e0f2f8bedd89a8f66890e06ba410",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "e1695034dbfec9cdf0e127a3c3075335",
"assets/fonts/MaterialIcons-Regular.otf": "0db35ae7a415370b89e807027510caf0",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/record_web/assets/js/record.worklet.js": "356bcfeddb8a625e3e2ba43ddf1cc13e",
"assets/packages/flutter_image_compress_web/assets/pica.min.js": "6208ed6419908c4b04382adc8a3053a2",
"assets/packages/fluttertoast/assets/toastify.css": "910ddaaf9712a0b0392cf7975a3b7fb5",
"assets/packages/fluttertoast/assets/toastify.js": "18cfdd77033aa55d215e8a78c090ba89",
"assets/assets/fonts/NotoColorEmoji-Regular.ttf": "05b8319e9ca8c424f92581503927e872",
"assets/assets/images/splash.png": "eea785b49038bc477b11fa751242220f",
"assets/assets/images/img_not_available.jpg": "f2fb658621b4a331335db0e56b1fbdd6",
"assets/lib/images/pokelab.png": "d95860966d9a0aa63d987aab67c3d8be",
"assets/lib/images/boyUp1.png": "1849e418240e007bb6a4e5a887cb191e",
"assets/lib/images/boyUp2.png": "937f0ee96369861c3bed5abe23f10757",
"assets/lib/images/boyLeft0.png": "e97bf4c320ce4617b45e19b92ca555be",
"assets/lib/images/littleroot.png": "a20048af90a0ed753ab65ba6047b92f1",
"assets/lib/images/littleroot_sheet.png": "5d3c8c519b6d879393dcc495f4a91920",
"assets/lib/images/boyRight1.png": "d1264a887d057a36893980bb9595b4d6",
"assets/lib/images/boyDown1.png": "e555be425284c00a7433d6894ca8295b",
"assets/lib/images/boyRight0.png": "97480b58275119fdfcc6e2cf3fa2900c",
"assets/lib/images/boyRight2.png": "2b650ad848e76a7703545731532bc53f",
"assets/lib/images/boyLeft2.png": "582c2f5fb4688fd6263907f09910a971",
"assets/lib/images/boy_sheet.png": "739206252f6b7caec74376f2fb819c7b",
"assets/lib/images/boyUp0.png": "9e6ae905d858a455c3e64da518ebe8f1",
"assets/lib/images/boyDown0.png": "9024ce3e506db9c846948819439a0715",
"assets/lib/images/boyLeft1.png": "1275c0c06cbc93ee5b26f62f361f3cda",
"assets/lib/images/boyDown2.png": "1c7d2fcdbe6611af926039c14a66d145",
"assets/NOTICES": "938842f1aeb30f4cebef96dba77a5e5a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.json": "a880a730ab1fd5984bfaf624619a5eba",
"assets/AssetManifest.bin.json": "1f9f7ae4602b02ed6828d6dd52fbc217",
"index.html": "da597936cf6f222b8045d1b68c64a268",
"/": "da597936cf6f222b8045d1b68c64a268",
"manifest.json": "354bec2e18572e000457749fdce63207",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"firebase-messaging-sw.js": "2388f288a67e94b6646cdf7a1b1d51d4",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/favicon-16x16.png": "1fcc687e538a1fa2310543ea74432dd7",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/favicon.ico": "33df157f932cc0af7754871debe8e8c2",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/favicon-32x32.png": "b664008f33a310f05ef871d037f27da0",
"icons/Icon": "68b329da9893e34099c7d8ad5cb9c940",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"version.json": "0bbc483ed6414f636f5680e6f02d7759",
"flutter_bootstrap.js": "720d78913aac0d76bd00fbfe05b75872"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
