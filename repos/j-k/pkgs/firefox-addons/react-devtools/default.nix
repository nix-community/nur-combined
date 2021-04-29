{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "react-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3767928/react_developer_tools-4.13.0-fx.xpi";
  sha256 = "sha256-5/3tE3QKVdccwpvd9ywQ8lmE2z0iKN/ltrmY3jTZZ8Y=";

  # meta = with lib; {
  #   homepage = "https://github.com/facebook/react/tree/master/packages/react-devtools-extensions/";
  #   description = "An addon for inspection React applications";
  #   longDescription = ''
  #     Browser extension that allows you to inspect a React component
  #     hierarchy, including props and state.
  #   '';
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jk ];
  # };
}
