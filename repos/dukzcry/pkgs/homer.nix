{ lib, stdenv, fetchurl, unzip, configuration ? {}, writeText }:

let
  configuration' = writeText "config.yml" (builtins.toJSON configuration);
in stdenv.mkDerivation rec {
  pname = "homer";
  version = "24.05.1";

  src = fetchurl {
    urls = [
      "https://github.com/bastienwirtz/${pname}/releases/download/v${version}/${pname}.zip"
    ];
    sha256 = "sha256-Ji/7BSKCnnhj4NIdGngTHcGRRbx9UWrx48bBsKkEj34=";
  };
  nativeBuildInputs = [ unzip ];

  dontInstall = true;
  sourceRoot = ".";
  unpackCmd = "${lib.getExe unzip} -d $out $curSrc";

  buildPhase = lib.optionalString (configuration != {}) ''
    cp ${configuration'} $out/assets/config.yml
  '';

  meta = with lib; {
    description = "A very simple static homepage for your server";
    homepage = "https://github.com/bastienwirtz/homer";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
