{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "refined-github-";
  url = "https://addons.mozilla.org/firefox/downloads/file/3741342/refined_github-21.3.11-an+fx.xpi";
  sha256 = "sha256-7aSnHRujwQexUvCkCrJumGaG/0CtG/1tLbm2CCr9KkY=";

  # meta = with lib; {
  #   homepage = "https://github.com/sindresorhus/refined-github/";
  #   changelog = "https://github.com/sindresorhus/refined-github/releases/";
  #   description = "An addon that simplifies the GitHub interface and adds useful features";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
