{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "https-everywhere";
  url = "https://addons.mozilla.org/firefox/downloads/file/3716461/https_everywhere-2021.1.27-an+fx.xpi";
  sha256 = "sha256-2gSXSLunKCwPjAq4Wsj0lOeV551r3G+fcm1oeqjMKh8=";

  # meta = with lib; {
  #   https://github.com/EFForg/https-everywhere
  #   https://www.eff.org/files/https-everywhere-2021.1.27-eff.xpi
  #   homepage = "https://www.eff.org/https-everywhere/";
  #   changelog = "https://www.eff.org/files/Changelog.txt";
  #   description = "An addon that encrypts your communications with many websites that offer HTTPS but still allow unencrypted connections";
  #   license = licenses.gpl2Plus;
  #   maintainers = with maintainers; [ jk ];
  # };
}
