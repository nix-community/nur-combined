{ lib, fetchFromGitHub, rustPlatform }:
let
  pname = "reth";
  version = "1.1.0";
  hash = "sha256-VwBVfEJUU9ttxfKBHxCcIZjbdlLKe4fGOBUo0w9dsso=";
  cargoHash = "sha256-lf6B1UZALnf/XExAWUYTm7RHjXXaLCYEHxq00/1nFCQ=";
  src = fetchFromGitHub {
    inherit hash;
    owner = "paradigmxyz";
    repo = pname;
    rev = "v${version}";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src cargoHash;

  meta = with lib; {
    description = "Experience tranquillity while browsing the web without people tracking you!";
    homepage = "https://zen-browser.app";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
  };
}
