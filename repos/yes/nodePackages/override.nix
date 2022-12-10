{pkgs ? import <nixpkgs> {
  inherit system;
}, system ? builtins.currentSystem}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };
in
nodePackages // {
  aria2b = nodePackages.aria2b.override {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    preRebuild = ''
      makeWrapper $out/lib/node_modules/aria2b/app.js $out/bin/aria2b --suffix PATH : ${pkgs.ipset}/bin
    '';
  };
  md-to-pdf = nodePackages.md-to-pdf.override {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    prePatch = ''
      export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
    '';
    postInstall = ''
      wrapProgram $out/bin/md-to-pdf --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium}/bin/chromium
    '';
  };
}