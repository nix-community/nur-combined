{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "view-image";
  url = "https://addons.mozilla.org/firefox/downloads/file/3746023/view_image-3.4.1-an+fx.xpi";
  sha256 = "sha256-Q8I3SdPoaBLuPeGyR/c2SlPCqCnxVyUKSuBORIiApJU=";

  # meta = with lib; {
  #   homepage = "https://github.com/bijij/ViewImage/";
  #   description = "An addon to re-implement the 'View Image' and 'Search by image' buttons into google images";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
