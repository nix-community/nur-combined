{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "cors_everywhere";
  url = "https://addons.mozilla.org/firefox/downloads/file/1148493/cors_everywhere-18.11.13.2043-fx.xpi";
  sha256 = "sha256-EjKQbh+mK3s3asrah0rlJ1753YFoCIhme68BrqVPiE8=";

  # meta = with lib; {
  #   homepage = "https://github.com/spenibus/cors-everywhere-firefox-addon/";
  #   description = "An addon that allows you to alter requests to allow CORS everywhere";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
