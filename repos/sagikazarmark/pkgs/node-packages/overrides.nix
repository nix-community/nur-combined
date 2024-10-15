# Do not use overrides in this file to add  `meta.mainProgram` to packges. Use `./main-programs.nix`
# instead.
{ pkgs, nodejs }:

let
  inherit (pkgs)
    stdenv
    lib
    callPackage
    fetchFromGitHub
    fetchurl
    fetchpatch
    nixosTests;

  since = version: lib.versionAtLeast nodejs.version version;
  before = version: lib.versionOlder nodejs.version version;
in

final: prev: {
  decktape = prev.decktape.override (
    lib.optionalAttrs (!stdenv.isDarwin)
      {
        nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
        prePatch = ''
          export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
          export PUPPETEER_SKIP_DOWNLOAD=1
        '';
        postInstall = ''
          wrapProgram $out/bin/decktape \
          --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium.outPath}/bin/chromium
        '';
      } // {
      nativeBuildInputs = [ pkgs.buildPackages.makeWrapper pkgs.cacert ];
    }
  );
}
