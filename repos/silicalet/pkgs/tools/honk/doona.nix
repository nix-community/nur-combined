{
  lib,
  runCommand,
  fetchurl,
  src,
}:

let
  # Use the UI release and checksums paired with this Honk source tree.
  pins = lib.splitString "\n" (builtins.readFile "${src}/.github/ci/pins.env");
  pin = name: lib.removePrefix "${name}=" (
    lib.findFirst (lib.hasPrefix "${name}=") (throw "Missing ${name} in Honk's pins.env") pins
  );
  version = pin "DOONA_VERSION";
  fetchEdition = edition: sha256: fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v${version}/${edition}-${version}.tar.gz";
    inherit sha256;
  };
in
runCommand "doona-${version}"
  {
    standard = fetchEdition "doona" (pin "DOONA_SHA256");
    lite = fetchEdition "doona-lite" (pin "DOONA_LITE_SHA256");
  }
  ''
    mkdir -p "$out/doona" "$out/doona-lite"
    tar -xzf "$standard" -C "$out/doona"
    tar -xzf "$lite" -C "$out/doona-lite"
    for edition in doona doona-lite; do
      dir="$out/$edition"
      rm -rf "$dir/fonts"
      for file in LICENSE NOTICE THIRD-PARTY-NOTICES.txt $(grep -o 'LICENSES/[A-Za-z0-9.+-]*\.txt' "$dir/NOTICE"); do
        test -s "$dir/$file"
      done
    done
  ''
