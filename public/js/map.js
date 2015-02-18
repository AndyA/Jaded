$(function() {

  function CoordMapType(minv, maxv, alpha) {
    this.minv = minv;
    this.maxv = maxv;
    this.alpha = alpha;
  }

  $.extend(CoordMapType.prototype, (function() {
    return {
      tileSize: new google.maps.Size(256, 256),
      maxZoom: 19,
      name: "Tile #s",
      alt: "Wind Speed Map",

      _tileURL: function(y, x, size, zoom) {
        var xx = x * size;
        var yy = y * size;
        return '/map/ws/' + yy + '/' + xx + '/' + (yy + size) + '/' + (xx + size) + '/' + zoom;
      },

      _heatColour: function(v, a) {
        var vv = Math.pow(Math.max(0, Math.min(v, 1)), 0.5);
        var rgb = hsvToRgb(1 - vv, 1, vv);
        return 'rgba(' + Math.floor(rgb[0]) + ',' + Math.floor(rgb[1]) + ',' + Math.floor(rgb[2]) + ',' + a + ')';
      },

      getTile: function(coord, zoom, ownerDocument) {
        var $tile = $('<div class="map-tile"></div>').css({
          width: this.tileSize.width + 'px',
          height: this.tileSize.height + 'px'
        });

        // Get a 4 by 4 area
        var url = this._tileURL(coord.y, coord.x, 4, zoom + 2);
        var self = this;

        $.get(url).done(function(data) {
          for (var y = 0; y < data.length; y++) {
            var row = data[y];
            for (var x = 0; x < row.length; x++) {
              var col = self._heatColour((row[x] - self.minv) / (self.maxv - self.minv), self.alpha);
              if (row[x] >= self.minv) {
                $tile.append($('<div class="speed-tile"></div>').text(row[x]).css({
                  color: col
                }));
              }
              else {
                $tile.append($('<div class="speed-tile empty"></div>'));
              }
            }
          }
        });

        return $tile[0];
      },

      releaseTile: function(tile) {}

    }
  })());

  function makeMap($elt) {
    google.maps.event.addDomListener(window, 'load', function() {
      var mapOptions = {
        center: {
          lat: 51.507991,
          lng: -0.084682
        },
        zoom: 9
      };

      var map = new google.maps.Map($elt[0], mapOptions);
      map.overlayMapTypes.insertAt(0, new CoordMapType(4, 12, 1));
      return map;
    });
  }

  var map = makeMap($('#map'));

  function heatColour(v, a) {
    var vv = Math.max(0, Math.min(v, 1));
    var rgb = hsvToRgb(1 - v, 1, v / 2 + 0.3);
    return 'rgba(' + Math.floor(rgb[0]) + ',' + Math.floor(rgb[1]) + ',' + Math.floor(rgb[2]) + ',' + a + ')';
  }

  $('#key').each(function() {
    for (var i = 0; i < 20; i++) {
      var v = i / 20;
      var col = heatColour(Math.pow(v, 0.5), 1);
      $(this).append($('<div></div>').text(v).css({
        'background-color': col
      }));
    }
  });

});
