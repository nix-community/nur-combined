{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "sty-lus";
  url = "https://addons.mozilla.org/firefox/downloads/file/3732726/stylus-1.5.17-fx.xpi";
  sha256 = "sha256-bQ13DH6/iThTPux9VZUtCEXfPEexeDojtPUT5srljwk=";

  # meta = with lib; {
  #   https://github.com/openstyles/stylus/
  #   homepage = "https://add0n.com/stylus.html/";
  #   description = "A userstyles manager";
  #   license = licenses.gpl3;
  #   maintainers = with maintainers; [ jk ];
  # };
}
