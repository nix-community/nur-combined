{ lib, fetchurl, fetchFromGitHub, buildGoModule }:

let
  ver = "4.33.1";
  html = fetchurl {
    url = "https://github.com/authelia/authelia/releases/download/v${ver}/authelia-v${ver}-public_html.tar.gz";
    sha256 = "d5788ef35d4529be557360229f8053605273a1f593dc1a4f01fa35e6241fa31a";
  };
in
buildGoModule rec {
  pname = "authelia";
  version = ver;

  src = fetchFromGitHub {
    owner = "authelia";
    repo = "authelia";
    rev = "v${version}";
    sha256 = "sha256-HbXhmn9YnDQWky2sXSGcRepj5oONq1OomeWvV0OhZEw=";
  };

  vendorSha256 = "sha256-1tPuDDG9OGCKnpYJzVmLeEMNOVVJtoSTh0s2sBW/6j4=";

  subPackages = [ "cmd/authelia" ];

  ldflags = [ "-X github.com/authelia/authelia/v4/internal/utils.BuildTag=v${version}" ];

  prePatch = ''
    rm -rf internal/server/public_html
    tar -xzf ${html} -C internal/server
  '';

  meta = with lib; {
    description = "The Single Sign-On Multi-Factor portal for web apps.";
    homepage = "https://github.com/authelia/authelia";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
