{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "react-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3689412/react_developer_tools-4.10.1-fx.xpi";
  sha256 = "sha256-8InV1PgngrNNS62Ug7zBLQbLzfqDaebqUWpzbAd2ehY=";

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
