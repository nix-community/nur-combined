{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "https-everywhere";
  url = "https://addons.mozilla.org/firefox/downloads/file/3809748/https_everywhere-2021.7.13-an+fx.xpi";
  sha256 = "sha256-4mFGG11NNiEoX85wdzVYGE1pHGFLMwdE2rZy8DLbcxw=";

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
