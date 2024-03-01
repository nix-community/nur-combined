# From: https://github.com/NixOS/nixpkgs/issues/89268#issuecomment-636529668
{ stdenv, lib, buildGoModule, plugins ? [ ], vendorHash, ... }:
with lib;
let
  imports = lib.concatStrings (map (pkg: "\n\t_ \"${pkg}\"") plugins);
  main =
    "package main\n" +
    "import (\n" +
    "\tcaddycmd \"github.com/caddyserver/caddy/v2/cmd\"\n\n" +
    "\t_ \"github.com/caddyserver/caddy/v2/modules/standard\"" +
    "${imports}" +
    "\n)\n" +
    "func main() {\n" +
    "\tcaddycmd.Main()\n" +
    "}";
  sources = import ./sources.nix;
in
buildGoModule {
  pname = "caddy";
  version = sources.version;
  subPackages = [ "cmd/caddy" ];
  src = builtins.fetchTarball {
    url = "https://api.github.com/repos/caddyserver/caddy/tarball/v${sources.version}";
    sha256 = sources.hash;
  };
  passthru.updateScript = ./update.sh;
  inherit vendorHash;

  postPatch = ''
    		echo '${main}' > cmd/caddy/main.go
    		cat cmd/caddy/main.go
    	'';

  postConfigure = ''
    		cp vendor/go.sum ./
    		cp vendor/go.mod ./
    	'';

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
    maintainers = with maintainers; [ rushmorem fpletz zimbatm ];
  };
}
