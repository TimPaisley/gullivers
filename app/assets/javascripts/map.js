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

    window.app.ports.updateMap.subscribe(function (newLocation) {
        console.log (map, newLocation);
        if (newLocation) {
            if (!map) {
                var stopObserving = onElementCreate('map', function() {
                    map = new mapboxgl.Map({
                        container: 'map',
                        style: 'mapbox://styles/mapbox/streets-v9',
                        center: newLocation,
                        zoom: 12
                    });

                    stopObserving();
                });
            } else {
                map.panTo(newLocation);
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