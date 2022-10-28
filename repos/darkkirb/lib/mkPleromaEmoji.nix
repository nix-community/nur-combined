{
  stdenv,
  fetchurl,
  oxipng,
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
        libarchive
      ];
      unpackPhase = ''
        bsdtar -xf $src
      '';
      buildPhase = ''
        find . -type f -name '*.png' -execdir oxipng -o max -t $NIX_BUILD_CORES {} \;
      '';
      installPhase = ''
        mkdir $out
        cp -r * $out
      '';
      meta = with lib; {
        inherit (manifestData) description homepage;
        license = fixLicense manifestData.license;
      };
    }
    // args)
