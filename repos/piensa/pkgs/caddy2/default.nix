{ stdenv, go_1_12, buildGoPackage, fetchFromGitHub }:
let
  buildGoPackage12 = buildGoPackage.override { go=go_1_12; };
in buildGoPackage12 rec {
  name = "caddy-${version}";
  version = "2-${revision}";
  revision = "2dc4fcc62b";
  goPackagePath = "github.com/caddyserver/caddy";
  goDeps = ./deps.nix;
  subPackages = [ "cmd/caddy" ];
  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "${revision}";
    sha256 = "1lrvcmgpis1z0cvpkzp0wnrk1mk42h0cqgsgxbh61qbwbx5b24m1";
  };

  buildFlagsArray = ''
    -ldflags=
      -X github.com/caddyserver/caddy/v2/caddy/caddymain.gitTag=v${version}
  '';

  meta = with stdenv.lib; {
    homepage = https://caddyserver.com;
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
    maintainers = with maintainers; [ rushmorem fpletz zimbatm ];
  };
}
