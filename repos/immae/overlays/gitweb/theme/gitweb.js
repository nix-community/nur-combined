function include(filename, onload) {
  var head   = document.getElementsByTagName('head')[0];
  var script = document.createElement('script');
  script.src = filename;
  script.type = 'text/javascript';
  script.onload = script.onreadystatechange = function() {
    if (script.readyState) {
      if (script.readyState === 'complete' || script.readyState === 'loaded') {
        script.onreadystatechange = null;
        onload();
      }
    } 
    else {
      onload();
    }
  }
  head.appendChild(script);
}

include('static/gitweb.js', function() {});
include('//code.jquery.com/jquery-3.1.0.min.js', function() {
  $("div.title").each(function(index, element) {
    if ($(element).text() === "readme" || $(element).text() === " ") {
      $(element).hide();
    }
  });
});
