$(function() {

  function CoordMapType(minv, maxv, alpha, channel) {
    this.minv = minv;
    this.maxv = maxv;
    this.alpha = alpha;
    this.channel = channel;
  }

  $.extend(CoordMapType.prototype, (function() {
    var channels = ['datum', 'peak'];
    return {
      tileSize: new google.maps.Size(1024, 1024),

      _tileURL: function(y, x, size, zoom) {
        var xx = x * size;
        var yy = y * size;
        return '/map/ws/' + yy + '/' + xx + '/' + (yy + size) + '/' + (xx + size) + '/' + zoom;
      },

      _heatColour: function(v, a) {
        var vv = Math.pow(Math.max(0, Math.min(v, 1)), 0.5);
        var rgb = hsvToRgb((1 - vv) * 0.9, 1, vv);
        return 'rgba(' + Math.floor(rgb[0]) + ',' + Math.floor(rgb[1]) + ',' + Math.floor(rgb[2]) + ',' + a + ')';
      },

      setChannel: function(channel) {
        if (this.channel == channel) return;
        this.channel = channel;

        // Reflect change
        for (var c = 0; c < channels.length; c++) {
          var $elt = $('.map-tile .speed-set.' + channels[c]);
          if (channels[c] == channel) $elt.removeClass('hidden');
          else $elt.addClass('hidden');
        }
      },

      getTile: function(coord, zoom, ownerDocument) {
        var $tile = $('<div class="map-tile"></div>').css({
          width: this.tileSize.width + 'px',
          height: this.tileSize.height + 'px'
        });

        var url = this._tileURL(coord.y, coord.x, 16, zoom + 2);
        var self = this;

        $.get(url).done(function(data) {
          for (var c = 0; c < channels.length; c++) {
            var chan = channels[c];
            var $box = $('<div class="speed-set"></div>').addClass(chan);
            if (chan != self.channel) $box.addClass('hidden');
            for (var y = 0; y < data.datum.length; y++) {
              for (var x = 0; x < data.datum[y].length; x++) {
                var sample = data[chan][y][x];
                var $div = $('<div class="speed-tile"></div>');
                if (sample >= self.minv) {
                  var col = self._heatColour((sample - self.minv) / (self.maxv - self.minv), self.alpha);
                  $div.text(sample).css({
                    color: col
                  });
                }
                $box.append($div);
              }
            }
            $tile.append($box);
          }
        });

        return $tile[0];
      },

      releaseTile: function(tile) {}

    }
  })());

  function makeFragment(map) {
    return map.getCenter().toUrlValue() + ',' + map.getZoom() + ',' + getChannel();
  }

  function setFragment(map) {
    window.location.hash = makeFragment(map);
  }

  function parseFragment(frag) {
    if (frag == null || frag.length == 0 || frag.charAt(0) != '#') return null;
    return frag.substr(1).split(',');
  }

  function getChannel() {
    return $('#controls input:checked').val();
  }

  function makeMap($elt) {
    var frag = parseFragment(window.location.hash);

    var channel = 'datum';

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
      if (frag.length >= 4) {
        channel = frag[3];
      }
    }

    google.maps.event.addDomListener(window, 'load', function() {

      var map = new google.maps.Map($elt[0], mapOptions);
      var overlay = new CoordMapType(4, 12, 1, channel);
      map.overlayMapTypes.insertAt(0, overlay);

      google.maps.event.addListener(map, 'center_changed', function() {
        setFragment(map);
      });

      google.maps.event.addListener(map, 'zoom_changed', function() {
        setFragment(map);
      });

      $('#controls input:radio').change(function(ev) {
        var channel = $(this).val();
        overlay.setChannel(channel);
        setFragment(map);
      });
    });

    $('#controls input:radio[value="' + channel + '"]').prop('checked', true);
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
