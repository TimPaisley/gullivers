document.addEventListener('DOMContentLoaded', function () {
    function geo_success(position) {
        window.app.ports.receivePosition.send({ lat: position.coords.latitude, lng: position.coords.longitude });
    }

    function geo_error(error) {
        console.log (error);
    }

    var geo_options = {
        enableHighAccuracy: true,
        maximumAge        : 30000,
        timeout           : 27000
    };

    window.app.ports.getPosition.subscribe(function () {
        navigator.geolocation.getCurrentPosition(geo_success, geo_error, geo_options);
    });
});