{ stdenv, go_1_12, buildGoPackage, fetchFromGitHub }:
let
  buildGoPackage12 = buildGoPackage.override { go=go_1_12; };
in buildGoPackage12 rec {
  name = "caddy-${version}";
  version = "1.0.3";
  goPackagePath = "github.com/caddyserver/caddy";
  goDeps = ./deps.nix;
  subPackages = [ "caddy" ];

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v${version}";
    sha256 = "1n7i9w4vva5x5wry7gzkyfylk39x40ykv7ypf1ca3zbbk7w5x6mw";
  };


  buildFlagsArray = ''
    -ldflags=
      -X github.com/caddyserver/caddy/caddy/caddymain.gitTag=v${version}
  '';

  meta = with stdenv.lib; {
    homepage = https://caddyserver.com;
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
    maintainers = with maintainers; [ rushmorem fpletz zimbatm ];
  };
}
