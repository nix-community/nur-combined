# with import <nixpkgs> { };
{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "xdg-open-svc";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = "xdg-open-svc";
    rev = "v${version}";
    sha256 = "sha256-x6A6Fa2IRJKw9uAF7CmVbj4q8+LScaVnXPJ79fSBjY8=";
  };

  vendorHash = "sha256-qaHsTivC4hgdznEWSKQWKmGEkmeKwIz+0h1PIzYVVm8=";

  ldflags =
    [ "-s" "-w" "-X=main.version=${version}" "-X=main.builtBy=nixpkgs" ];

  meta = with lib; {
    description = "xdg-open as a service";
    homepage = "https://github.com/caarlos0/xdg-open-svc";
    license = licenses.mit;
  };
}
