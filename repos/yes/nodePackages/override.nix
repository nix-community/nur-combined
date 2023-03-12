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
    nativeBuildInputs = with pkgs; [ makeWrapper nodePackages.rollup ];
    postInstall = ''
      DEST=$out/lib/node_modules/shadowsocks-ws
      cd $DEST
      substituteInPlace local.mjs \
        --replace "./banner.txt" "$DEST/banner.txt"
      ln -s ${prev.express}/lib/node_modules/express $DEST/node_modules/express
      ln -s ${prev.http-proxy-middleware}/lib/node_modules/http-proxy-middleware $DEST/node_modules/http-proxy-middleware
      rollup -c
      mkdir -p $out/bin
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ss-ws-local \
        --add-flags "$DEST/local.mjs"
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ss-ws-server \
        --add-flags "$DEST/server.min.js"
    '';
  };
}