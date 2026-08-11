/*
  based on
  nixpkgs/pkgs/applications/networking/browsers/chromium/browser.nix
*/

{ lib
, chromium
}:

(chromium.mkDerivation (base: rec {
  name = "courgette";
  packageName = name;
  buildTargets = [ "courgette" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $buildPath/courgette $out/bin
  '';

  postFixup = ":";

  meta = {
    description = "binary diff/patch tool working on assembly code of compiled executables";
    homepage = "https://www.chromium.org/developers/design-documents/software-updates-courgette/";
    maintainers = [ ];
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "courgette";
  };
})).overrideAttrs (oldAttrs: {
  name = "courgette-${chromium.browser.version}";
})
