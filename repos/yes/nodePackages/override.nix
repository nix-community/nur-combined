{pkgs ? import <nixpkgs> {
  inherit system;
}, system ? builtins.currentSystem}:

let
  prev = import ./default.nix {
    inherit pkgs system;
  };
in {
  inherit (prev) magireco-cn-local-server;
  aria2b = prev.aria2b.override {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    preRebuild = ''
      makeWrapper $out/lib/node_modules/aria2b/app.js $out/bin/aria2b --suffix PATH : ${pkgs.ipset}/bin
    '';
  };
  shadowsocks-ws = prev."shadowsocks-ws-git+https://github.com/totravel/shadowsocks-ws.git".override {
    postInstall = ''
      DEST=$out/lib/node_modules/shadowsocks-ws
      substituteInPlace $DEST/local.mjs \
        --replace "./banner.txt" "$DEST/banner.txt"
    '';
  };
}