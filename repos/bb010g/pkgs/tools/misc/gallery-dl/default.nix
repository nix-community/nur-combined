{ lib, python3Packages, buildPackages, fetchFromGitHub
, enableCloudflare ? true
, enableConversion ? true
, ffmpeg ? null
, enableVideo ? true
, youtube-dl ? null
}:

let
  pyPkgs = python3Packages;
  inherit (lib) optionals;
in

assert enableCloudflare -> pyPkgs.pyopenssl != null;
assert enableConversion -> ffmpeg != null;
assert enableVideo -> youtube-dl != null;

pyPkgs.buildPythonApplication rec {
  pname = "gallery-dl";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "mikf";
    repo = "gallery-dl";
    rev = "v${version}";
    sha256 = "1jmksasl5q3lhp8yxrnlplid060zf9rxgxd78061xljb1zilvcs6";
  };

  outputs = [ "out" "man" "doc" ];

  nativeBuildInputs = [
    buildPackages.python3
  ];

  propagatedBuildInputs = [
    pyPkgs.requests
  ] ++ optionals enableCloudflare [
    pyPkgs.pyopenssl
  ] ++ optionals enableConversion [
    ffmpeg
  ] ++ optionals enableVideo [
    youtube-dl
  ];

  preBuild = ''
    make all PYTHON=${buildPackages.python3}/bin/python3
  '';

  doCheck = false;
  checkInputs = [
    (lib.getBin pyPkgs.nose)
  ];

  postInstall = ''
    mkdir -p "''${!outputDoc}/share/doc/gallery-dl"
    cp -t "''${!outputDoc}/share/doc/gallery-dl" docs/*
  '';

  meta = {
    description =
      "A CLI image-gallery & -collection downloader for several image hosts";
    homepage = https://github.com/mikf/gallery-dl;
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ bb010g ];
  };
}
