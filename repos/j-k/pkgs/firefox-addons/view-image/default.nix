{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "view-image";
  url = "https://addons.mozilla.org/firefox/downloads/file/3556331/view_image-3.3.1-an+fx.xpi";
  sha256 = "sha256-QTnstZwhb28yv18wfoF5v6u7b+r/D8efM+pg27X/lo0=";

  # meta = with lib; {
  #   homepage = "https://github.com/bijij/ViewImage/";
  #   description = "An addon to re-implement the 'View Image' and 'Search by image' buttons into google images";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
