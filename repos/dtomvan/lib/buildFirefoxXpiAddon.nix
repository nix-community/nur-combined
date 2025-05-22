args@{
  lib,
  stdenv,
  fetchurl,
}:
lib.makeOverridable (
  {
    stdenv ? args.stdenv,
    fetchurl ? args.fetchurl,
    pname,
    version,
    addonId,
    url ? null,
    hash ? null,
    meta,
    src ? fetchurl { inherit url hash; },
    ...
  }:
  stdenv.mkDerivation {
    name = "${pname}-${version}";

    inherit meta src;

    preferLocalBuild = true;
    allowSubstitutes = true;

    passthru = { inherit addonId; };

    buildCommand = ''
      dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
      mkdir -p "$dst"
      install -v -m644 "$src" "$dst/${addonId}.xpi"
    '';
  }
)
