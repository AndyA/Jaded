requirejs.config({
  "baseUrl": "/dirt/js",
  "map": {
    '*': {
      'jquery': 'jquery-private'
    },
    'jquery-private': {
      'jquery': 'jquery'
    }
  },
  "paths": {
    "jquery": "//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min"
  }
});

require(['jquery'], function($) {
  console.log($);
});
