# with import <nixpkgs> { };
{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "clone-org";
  version = "1.5.2";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = "clone-org";
    rev = "v${version}";
    sha256 = "sha256-iYpCQOXvyd6ZDhInr3Jodrj2brU6lAR2K+L1z++i37E=";
  };

  vendorHash = "sha256-B52WZ+ri2jIWN48c5lDz4NrjX8OInTeNLn6ZFn4sP70=";

  ldflags =
    [ "-s" "-w" "-X=main.version=${version}" "-X=main.builtBy=nixpkgs" ];

  meta = with lib; {
    description = "Clone all repos of a github organization";
    homepage = "https://github.com/caarlos0/clone-org";
    license = licenses.mit;
  };
}
