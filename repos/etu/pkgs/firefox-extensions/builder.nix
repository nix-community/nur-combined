{
  stdenv,
  fetchurl,
  ...
}: {
  pname,
  version,
  addonId,
  url,
  sha256,
  meta ? {},
  ...
}:
stdenv.mkDerivation {
  inherit meta pname version;

  src = fetchurl {inherit url sha256;};

  buildCommand = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    install -v -m644 "$src" "$dst/${addonId}.xpi"
  '';
}
