document.addEventListener('DOMContentLoaded', function () {
    function geo_success(position) {
        window.app.ports.receiveGeoData.send(position);
    }

    function geo_error(error) {
        window.app.ports.receiveGeoData.send(error.message);
    }

    var geo_options = {
        enableHighAccuracy: true,
        maximumAge        : 30000,
        timeout           : 27000
    };

    window.app.ports.enableGeolocation.subscribe(function () {
        navigator.geolocation.watchPosition(geo_success, geo_error, geo_options);
    });
});