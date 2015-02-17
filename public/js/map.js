$(function() {

  function CoordMapType() {}

  CoordMapType.prototype.tileSize = new google.maps.Size(128, 128);
  CoordMapType.prototype.maxZoom = 19;

  CoordMapType.prototype.getTile = function(coord, zoom, ownerDocument) {
    var $tile = $('<div class="map-tile"></div>').css({
      width: this.tileSize.width + 'px',
      height: this.tileSize.height + 'px'
    }).text('pos: ' + coord + ', zoom: ' + zoom);;
    return $tile[0];
  };

  CoordMapType.prototype.name = "Tile #s";
  CoordMapType.prototype.alt = "Tile Coordinate Map Type";

  function makeMap($elt) {
    google.maps.event.addDomListener(window, 'load', function() {
      var mapOptions = {
        center: {
          lat: 51.507991,
          lng: -0.084682
        },
        zoom: 13
      };

      var map = new google.maps.Map($elt[0], mapOptions);
      map.overlayMapTypes.insertAt(0, new CoordMapType());
      return map;
    });
  }

  var map = makeMap($('#map'));

});
