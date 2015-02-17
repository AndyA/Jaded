$(function() {

  function makeMap($elt) {;
    google.maps.event.addDomListener(window, 'load', function() {
      var mapOptions = {
        center: {
          lat: 51.507991,
          lng: -0.084682
        },
        zoom: 13
      };
      return new google.maps.Map($elt[0], mapOptions);
    });
  }

  var map = makeMap($('#map'));

});
