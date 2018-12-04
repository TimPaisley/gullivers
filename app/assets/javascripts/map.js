mapboxgl.accessToken = 'pk.eyJ1IjoidGltcGFpc2xleXdjYyIsImEiOiJjam9mODZ5bnIwMXFpM2tueDJqbTU5YjI0In0.91UVSWOXuqvG2_1x6nMMVw';

function onElementCreate(id, callback) {
    if (document.getElementById(id)) {
        requestAnimationFrame(callback);
        return function () {};
    }
    
    var observer = new MutationObserver(function (mutations) {
        if (document.getElementById(id)) {
            callback();
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    return function () {
        observer.disconnect();
    }
}

document.addEventListener('DOMContentLoaded', function () {
    var map;

    window.app.ports.updateMap.subscribe(function (options) {
        console.log (map, options);
        if (options) {
            if (!map) {
                var stopObserving = onElementCreate('map', function() {
                    map = new mapboxgl.Map({
                        container: 'map',
                        style: 'mapbox://styles/timpaisleywcc/cjp2dq5g420mw2sqimr5unpup',
                        center: options.focus,
                        zoom: 13
                    });

                    if (options.locations) {
                        options.locations.forEach(function (loc) {
                            new mapboxgl.Marker({ color: "#65a384" })
                                .setLngLat([loc.lng, loc.lat])
                                .addTo(map);
                        });
                    }

                    stopObserving();
                });
            } else {
                map.panTo(options.focus);
            }
                    
        } else {
            if (map) {
                console.log('removing map!')
                map.remove();
                map = null;
            }
        }
    });
});