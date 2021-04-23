{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "preact-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3760867/preact_developer_tools-1.4.0-fx.xpi";
  sha256 = "sha256-1TEPmUKfQCFoOJ/LsDa6xwb7kKJcWlZ16WjwUMxPY7Y=";

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
