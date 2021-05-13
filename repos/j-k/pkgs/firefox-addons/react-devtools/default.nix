{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "react-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3772652/react_developer_tools-4.13.2-fx.xpi";
  sha256 = "sha256-wpcwMOnhLTyDiqX7PBCwnCE1pZiX14DtakHO++gCIRI=";

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
