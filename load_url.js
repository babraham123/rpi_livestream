
phantom.onError = function(msg, trace) {
  console.log('PHANTOM_ERROR\n' + msg);
  phantom.exit(1);
};
var page = require('webpage').create();
page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36";
page.onError = function(msg, trace) {
  console.error('PAGE_ERROR\n' + msg);
  phantom.exit(1);
};
page.open('http://www.eastafro.com/EriTV1/', function () {
  console.log('PAGE_SUCCESS');
  phantom.exit();
});
