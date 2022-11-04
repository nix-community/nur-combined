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
  reveal-md = prev.reveal-md.override (
    if stdenv.isDarwin
    then {
      postInstall = ''
        patch -d $out/lib/node_modules/reveal-md -p1 < ${./patches/0001-fix-copy-the-correct-favicon-when-building-static-si.patch}
      '';
      }
    else {
      nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
      prePatch = ''
        export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
      '';
      postInstall = ''
        patch -d $out/lib/node_modules/reveal-md -p1 < ${./patches/0001-fix-copy-the-correct-favicon-when-building-static-si.patch}

        wrapProgram $out/bin/reveal-md \
        --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium.outPath}/bin/chromium
      '';
    }
  );
}
