{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "refined-github-";
  url = "https://addons.mozilla.org/firefox/downloads/file/3754309/refined_github-21.4.2-an+fx.xpi";
  sha256 = "sha256-LpUCp6GH0fJYdOy3zCbLRh5VhKfjTD0gKIVuAmvhE2I=";

  # meta = with lib; {
  #   homepage = "https://github.com/sindresorhus/refined-github/";
  #   changelog = "https://github.com/sindresorhus/refined-github/releases/";
  #   description = "An addon that simplifies the GitHub interface and adds useful features";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
