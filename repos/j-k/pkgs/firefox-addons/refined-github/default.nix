{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "refined-github-";
  url = "https://addons.mozilla.org/firefox/downloads/file/3808553/refined_github-21.7.12-an+fx.xpi";
  sha256 = "sha256-vvien+JMimyhEgXl2psxRj96j8ok8kKlfxruBJW6lSg=";

  # meta = with lib; {
  #   homepage = "https://github.com/sindresorhus/refined-github/";
  #   changelog = "https://github.com/sindresorhus/refined-github/releases/";
  #   description = "An addon that simplifies the GitHub interface and adds useful features";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
