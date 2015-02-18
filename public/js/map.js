$(function() {

  function CoordMapType(minv, maxv, alpha, channel) {
    this.minv = minv;
    this.maxv = maxv;
    this.alpha = alpha;
    this.channel = channel || 'datum';
  }

  $.extend(CoordMapType.prototype, (function() {
    return {
      tileSize: new google.maps.Size(1024, 1024),

      _tileURL: function(y, x, size, zoom) {
        var xx = x * size;
        var yy = y * size;
        return '/map/ws/' + this.channel + '/' + yy + '/' + xx + '/' + (yy + size) + '/' + (xx + size) + '/' + zoom;
      },

      _heatColour: function(v, a) {
        var vv = Math.pow(Math.max(0, Math.min(v, 1)), 0.5);
        var rgb = hsvToRgb((1 - vv) * 0.9, 1, vv);
        return 'rgba(' + Math.floor(rgb[0]) + ',' + Math.floor(rgb[1]) + ',' + Math.floor(rgb[2]) + ',' + a + ')';
      },

      getTile: function(coord, zoom, ownerDocument) {
        var $tile = $('<div class="map-tile"></div>').css({
          width: this.tileSize.width + 'px',
          height: this.tileSize.height + 'px'
        });

        var url = this._tileURL(coord.y, coord.x, 16, zoom + 2);
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

  function makeFragment(map) {
    return map.getCenter().toUrlValue() + ',' + map.getZoom();
  }

  function setFragment(map) {
    window.location.hash = makeFragment(map);
  }

  function parseFragment(frag) {
    if (frag == null || frag.length == 0 || frag.charAt(0) != '#') return null;
    return frag.substr(1).split(',');
  }

  function makeMap($elt) {
    var frag = parseFragment(window.location.hash);

    var mapOptions = {
      center: {
        lat: 54.780986,
        lng: -4.259487
      },
      zoom: 7,
      mapTypeId: google.maps.MapTypeId.SATELLITE
    };

    if (frag) {
      if (frag.length >= 2) {
        mapOptions.center.lat = 1 * frag[0];
        mapOptions.center.lng = 1 * frag[1];
      }
      if (frag.length >= 3) {
        mapOptions.zoom = 1 * frag[2];
      }
    }

    google.maps.event.addDomListener(window, 'load', function() {

      var map = new google.maps.Map($elt[0], mapOptions);
      map.overlayMapTypes.insertAt(0, new CoordMapType(4, 12, 1, 'peak'));

      google.maps.event.addListener(map, 'center_changed', function() {
        setFragment(map);
      });

      google.maps.event.addListener(map, 'zoom_changed', function() {
        setFragment(map);
      });

      setFragment(map);
    });
  }

  makeMap($('#map'));

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
