{ lib, buildGo126Module, fetchFromGitHub }:
let
  version = "2.62.3";
in
buildGo126Module {
  pname = "aqua";
  inherit version;

  src = fetchFromGitHub {
    owner = "aquaproj";
    repo = "aqua";
    tag = "v${version}";
    hash = "sha256-SrkSel+hiUIRAip/U3ODFkLBkqFjVKjar6TbkQab+lE=";
  };

  vendorHash = "sha256-PLtYXYpbZKHDzvK589wZtpVcv2YIBxLruHLHKbRjM30=";
  subPackages = [ "cmd/aqua" ];
  ldflags = [ "-s" "-w" "-X=main.version=${version}" ];

  meta = {
    description = "Declarative CLI Version manager written in Go. Support Lazy Install, Registry, and continuous update by Renovate";
    homepage = "https://aquaproj.github.io/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "aqua";
  };
}
