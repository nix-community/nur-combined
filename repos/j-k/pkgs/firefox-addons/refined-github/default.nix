{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "refined-github-";
  url = "https://addons.mozilla.org/firefox/downloads/file/3774069/refined_github-21.5.10-an+fx.xpi";
  sha256 = "sha256-as/j2Qkcat6EcwIeM4Di969ahOB3Ed8CPo3WdJGq5jA=";

  # meta = with lib; {
  #   homepage = "https://github.com/sindresorhus/refined-github/";
  #   changelog = "https://github.com/sindresorhus/refined-github/releases/";
  #   description = "An addon that simplifies the GitHub interface and adds useful features";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
