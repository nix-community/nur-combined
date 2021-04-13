{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "react-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3758027/react_developer_tools-4.11.0-fx.xpi";
  sha256 = "sha256-Xs0cwD+zPQXveB8dzguP1GIv0rlhea85hwKk5IaG9zs=";

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
