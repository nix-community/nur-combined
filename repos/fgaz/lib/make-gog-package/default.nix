# Make a package from a gog installer, wrapping it with steam-run-native

# what you want the binary in $out/bin to be called
{ binname
# the name of the gog installer, eg. "enter_the_gungeon" if the installer is
# called enter_the_gungeon_2_1_9_33951.sh
, installername
, pname
# version of the game, in the above example "2_1_9_33951"
, version
# hash of the installer
, sha256
# optional meta attribute set
, meta ? {}
}:

{ stdenv
, requireFile
, zip
, unzip
, makeWrapper
, steam-run-native
}:

stdenv.mkDerivation {
  inherit pname version meta;

  src = requireFile {
    name = "${installername}_${version}.sh";
    inherit sha256;
    message = ''
      Please purchase the game on gog.com and download the Linux installer.

      Once you have downloaded the file, please use the following command and re-run the
      installation:

      nix-prefetch-url file://\$PWD/${installername}_${version}.sh
    '';
  };

  nativeBuildInputs = [
    zip
    unzip
    makeWrapper
  ];

  unpackPhase = ''
    zip -F $src --out fixed.zip
    unzip -d source fixed.zip
  '';
  sourceRoot = "source";

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/share
    cp -r * $out/share/
    makeWrapper \
      ${steam-run-native}/bin/steam-run \
      $out/bin/${binname} \
      --add-flags $out/share/data/noarch/start.sh
  '';
}
