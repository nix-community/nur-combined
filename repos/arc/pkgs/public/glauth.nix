{ lib, git, fetchFromGitHub, buildGoModule, go-bindata }:

buildGoModule rec {
  pname = "glauth";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "glauth";
    repo = pname;
    rev = "v${version}";
    sha256 = "0g4a3rp7wlihn332x30hyvqb5izpcd7334fmghhvbv0pi4p7x9bf";
  };

  vendorHash = "sha256:0ljxpscs70w1zi1dhg0lhc31161380pfwwqrr32pyxvxc48mjj25";

  nativeBuildInputs = [ go-bindata ];

  ldflags = [ "-X main.LastGitTag=v${version}" "-X main.GitTagIsCommit=1" ];

  preBuild = "go-bindata -pkg=assets -o=pkg/assets/bindata.go assets";

  preInstall = let
    plugins = ["sqlite" "postgres" "mysql"];
    pluginLine = plugin: ''go build -ldflags "''${ldflags[*]}" -buildmode=plugin -o $out/bin/${plugin}.so pkg/plugins/${plugin}.go pkg/plugins/basesqlhandler.go'';
    pluginLines = map pluginLine plugins;
  in lib.concatStringsSep "\n" pluginLines;

  doCheck = false;

  meta = with lib; {
    description = "A lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
