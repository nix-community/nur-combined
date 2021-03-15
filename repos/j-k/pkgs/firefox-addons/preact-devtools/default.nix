{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "preact-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3714041/preact_developer_tools-1.3.0-fx.xpi";
  sha256 = "sha256-g2+l/x4ssUhwNc0frK0Acf9nlYgWql7Wx5aaVHGnZlU=";

  # meta = with lib; {
  #   homepage = "https://preactjs.github.io/preact-devtools/";
  #   changelog = "https://github.com/preactjs/preact-devtools/blob/master/CHANGELOG.md/;
  #   description = "An addon for inspection Preact applications";
  #   longDescription = ''
  #     Browser extension that allows you to inspect a Preact component
  #     hierarchy, including props and state.
  #   '';
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
