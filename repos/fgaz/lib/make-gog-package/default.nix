{ binname, installername, pname, version, sha256, meta ? {} }:
{ stdenv, requireFile, zip, unzip, makeWrapper, steam-run }:

stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = requireFile {
    name = "${installername}_${version}.sh";
    sha256 = sha256;
    message = ''
      Please purchase the game on gog.com and download the Linux installer.

      Once you have downloaded the file, please use the following command and re-run the
      installation:

      nix-prefetch-url file://\$PWD/${installername}_${version}.sh
    '';
  };

  nativeBuildInputs = [ zip unzip makeWrapper ];
  buildInputs = [ steam-run ];

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
      ${steam-run}/bin/steam-run \
      $out/bin/${binname} \
      --add-flags $out/share/data/noarch/start.sh
  '';

  meta = meta;

}

