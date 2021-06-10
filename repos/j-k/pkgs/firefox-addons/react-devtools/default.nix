{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "react-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3781975/react_developer_tools-4.13.5-fx.xpi";
  sha256 = "sha256-05f8ez4resV9L6vzgECHMcaU3VKvqHHngI37s1MbYjo=";

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
