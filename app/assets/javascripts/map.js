mapboxgl.accessToken = 'pk.eyJ1IjoidGltcGFpc2xleXdjYyIsImEiOiJjam9mODZ5bnIwMXFpM2tueDJqbTU5YjI0In0.91UVSWOXuqvG2_1x6nMMVw';
// const mapStyle = 'mapbox://styles/timpaisleywcc/cjpcdf5taanva2rju1u7luuyo';
// const markerColor = '#FFCC00';

var mapStyle = 'mapbox://styles/timpaisleywcc/cjp2dq5g420mw2sqimr5unpup';
var markerColor = '#769e8a';

function onElementCreate(id, callback) {
    if (document.getElementById(id)) {
        requestAnimationFrame(callback);
        return function () { };
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
    var pos;

    window.app.ports.updateMap.subscribe(function (options) {
        if (options) {
            if (!map) {
                var stopObserving = onElementCreate('map', function () {
                    map = new mapboxgl.Map({
                        container: 'map',
                        style: mapStyle,
                        center: options.initialFocus,
                        zoom: 13
                    });

                    if (options.locations) {
                        options.locations.forEach(function (loc) {
                            new mapboxgl.Marker({ color: markerColor })
                                .setLngLat([loc.lng, loc.lat])
                                .addTo(map);
                        });
                    }

                    stopObserving();
                });
            } else {
                if (options.position) {
                    if (pos) { pos.remove(); }

                    pos = new mapboxgl.Marker({ color: '#FFCC00' })
                        .setLngLat([options.position.lng, options.position.lat])
                        .addTo(map);
                }
            }

        } else {
            if (map) {
                map.remove();
                map = null;
                pos = null;
            }
        }
    });

    window.app.ports.focusMap.subscribe(function (position) {
        if (map) {
            map.panTo(position);
        }
    });
});