{ lib
, stdenv
, fetchurl
, undmg
, makeBinaryWrapper
}:
stdenv.mkDerivation rec {
  pname = "alfred";
  version = "5.1.4_2195";

  appname = "Alfred ${lib.versions.major version}";

  nativeBuildInputs = [
    undmg
    makeBinaryWrapper
  ];

  src = fetchurl {
    url = "https://cachefly.alfredapp.com/Alfred_${version}.dmg";
    sha256 = "6d5f4e3077fe5cda0f96120cad1c501af599d7897ffba25cf0850a98e44a5ff2";
  };

  sourceRoot = "${appname}.app";
  dontPatchShebangs = true; # If the application files are modified, the signature will be invalid, and MacOS will prevent the application from launching

  installPhase = ''
    mkdir -p $out/Applications/"${appname}".app
    cp -r . $out/Applications/"${appname}".app
  '';
}
