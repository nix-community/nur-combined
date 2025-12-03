# dash nixpkgs docset tracking issue: <https://github.com/Kapeli/Dash-User-Contributions/issues/4812>
# this package is heavily based on:
# - <https://github.com/nixosbrasil/nix-docgen>
# - <https://kapeli.com/docsets#dashDocset>
{
  buildPackages,
  docsets,
  lib,
  # nixpkgs-manual,
  stdenvNoCC,
}:
let
  # nixpkgs has logic to build an attrset of all the items which make it into nixpkgs-manual.
  # this is a json dictionary with each entry like:
  # - `"lib.asserts.assertEachOneOf": "[lib/asserts.nix:135](https://github.com/NixOS/nixpkgs/blob/master/lib/asserts.nix#L135) in `<nixpkgs>`"`
  # TODO: upstream nixpkgs `lib-docs` package could probably be fixed to cross-compile instead of grabbing it from `buildPackages`
  nixpkgs-manual = buildPackages.nixpkgs-manual;
  lib-locations = nixpkgs-manual.lib-docs.overrideAttrs (base: {
    installPhase = base.installPhase + ''
      cp locations.json $out/locations.json
    '';
  });

in stdenvNoCC.mkDerivation {
  pname = "nixpkgs-lib";
  version = lib.version;

  nativeBuildInputs = [ docsets.make-docset-index ];

  unpackPhase = ''
    cp ${./Info.plist} Info.plist
    cp ${lib-locations}/locations.json locations.json
    cp -R ${nixpkgs-manual}/share/doc/nixpkgs nixpkgs-manual
  '';

  buildPhase = ''
    runHook preBuild

    mkdir -p nixpkgs-lib.docset/Contents/Resources/
    cp Info.plist nixpkgs-lib.docset/Contents/
    cp -R nixpkgs-manual nixpkgs-lib.docset/Contents/Resources/Documents

    make-docset-index --verbose locations.json --output nixpkgs-lib.docset/Contents/Resources/docSet.dsidx

    runHook postBuild
  '';

  # docsets are usually distributed as .tgz, but compression is actually optional at least for tools like `dasht`
  installPhase = ''
    mkdir -p $out/share/docsets
    cp -R *.docset $out/share/docsets/
  '';

  passthru = {
    inherit lib-locations;
  };
}
