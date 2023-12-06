# with import <nixpkgs> { };
{ buildGoModule, fetchFromGitHub, lib, ... }:
buildGoModule rec {
  pname = "gocovsh";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "orlangure";
    repo = "gocovsh";
    rev = "v${version}";
    sha256 = "sha256-VZNu1uecFVVDgF4xDLTgkCahUWbM+1XASV02PEUfmr0=";
  };

  vendorHash = "sha256-Fb7BIWojOSUIlBdjIt57CSvF1a+x33sB45Z0a86JMUg=";

  ldflags =
    [ "-s" "-w" "-X=main.version=${version}" "-X=main.builtBy=nixpkgs" ];

  meta = with lib; {
    description =
      "Go Coverage in your terminal: a tool for exploring Go Coverage reports from the command line";
    homepage = "https://github.com/orlangure/gocovsh";
    license = licenses.gpl3;
  };
}
