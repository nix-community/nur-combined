{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "https-everywhere";
  url = "https://addons.mozilla.org/firefox/downloads/file/3760520/https_everywhere-2021.4.15-an+fx.xpi";
  sha256 = "sha256-j2NCB3UVZp9zrjdzRtpER0KFRFWchwZ4SI+ltrY9JQA=";

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
