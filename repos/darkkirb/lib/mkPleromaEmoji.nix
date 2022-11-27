{
  stdenv,
  fetchurl,
  oxipng,
  pngquant,
  lib,
  libarchive,
}: {
  name,
  manifest,
  ...
} @ args: let
  manifestData = (builtins.fromJSON (builtins.readFile manifest)).${name};
  src = fetchurl {
    url = manifestData.src;
    sha256 = manifestData.src_sha256;
  };
  brokenLicenses = {
    "CC BY-NC-SA 4.0" = lib.licenses.cc-by-nc-sa-20;
    "Apache 2.0" = lib.licenses.asl20;
  };
  fixLicense = license: brokenLicenses.${license} or license;
in
  stdenv.mkDerivation ({
      inherit name src;
      nativeBuildInputs = [
        oxipng
        pngquant
        libarchive
      ];
      unpackPhase = ''
        bsdtar -xf $src
      '';
      buildPhase = ''
        find . -type f -name '*.png' -execdir ${./crushpng.sh} {} {}.new 50000 \;
        for f in $(find . -type f -name '*.new'); do
          mv $f ${"$"}{f%.new}
        done
      '';
      installPhase = ''
        mkdir $out
        cp -r *.png $out
      '';
      meta = with lib; {
        inherit (manifestData) description homepage;
        license = fixLicense manifestData.license;
      };
    }
    // args)
