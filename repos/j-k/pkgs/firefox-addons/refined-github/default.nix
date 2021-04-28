{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "refined-github-";
  url = "https://addons.mozilla.org/firefox/downloads/file/3764936/refined_github-21.4.23-an+fx.xpi";
  sha256 = "sha256-8IzMdHQDuC+8zKrh/Z9rpcY+Hmf29fDC+eQECSdKUXs=";

  # meta = with lib; {
  #   homepage = "https://github.com/sindresorhus/refined-github/";
  #   changelog = "https://github.com/sindresorhus/refined-github/releases/";
  #   description = "An addon that simplifies the GitHub interface and adds useful features";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
