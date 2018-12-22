{ stdenv, fetchFromGitHub, nodePackages, buildBowerComponents }:

let

  name = "glowing-bear-${version}";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "glowing-bear";
    repo = "glowing-bear";
    rev = version;
    sha256 = "0gwrf67l3i3nl7zy1miljz6f3vv6zzc3g9as06by548f21cizzjb";
  };

  frontendPkgs = buildBowerComponents {
    name = "${name}-bower";
    generated = ./bower.nix;
    inherit src;
  };

in

stdenv.mkDerivation {

  inherit name src;

  buildInputs = [ nodePackages.uglify-js ];
  buildPhase = ''
    uglifyjs \
      ${frontendPkgs}/bower_components/angular/angular.min.js \
      ${frontendPkgs}/bower_components/angular-route/angular-route.min.js \
      ${frontendPkgs}/bower_components/angular-sanitize/angular-sanitize.min.js \
      ${frontendPkgs}/bower_components/angular-touch/angular-touch.min.js \
      ${frontendPkgs}/bower_components/underscore/underscore-min.js \
      ${frontendPkgs}/bower_components/emojione/lib/js/emojione.min.js \
      js/localstorage.js \
      js/weechat.js \
      js/irc-utils.js \
      js/glowingbear.js \
      js/settings.js \
      js/utils.js \
      js/notifications.js \
      js/filters.js \
      js/handlers.js \
      js/connection.js \
      js/file-change.js \
      js/imgur-drop-directive.js \
      js/whenscrolled-directive.js \
      js/inputbar.js \
      js/plugin-directive.js \
      js/websockets.js \
      js/models.js \
      js/bufferResume.js \
      js/plugins.js \
      js/imgur.js \
      -c -m --screw-ie8 -o min.js
  '';

  patches = [ ./remove-cloudflare-deps.patch ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r {directives,webapp.manifest.json,index.html,css,assets,3rdparty,min.js,serviceworker.js} $out
    cp ${frontendPkgs}/bower_components/bootstrap/dist/css/bootstrap.min.css $out/css

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "A web client for WeeChat";
    homepage = https://github.com/glowing-bear/glowing-bear;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ma27 ];
  };
}
