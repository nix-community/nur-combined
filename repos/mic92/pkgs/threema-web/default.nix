{ fetchzip }:
let
  version = "2.3.11";
in
fetchzip {
  url = "https://github.com/threema-ch/threema-web/releases/download/v${version}/threema-web-${version}-gh.tar.gz";
  sha256 = "sha256-1vczQJ49QmPmMwUr4MI2JJSaQdK8ioVJK+a7XgxB8O8=";
}
