{
  stdenv,
  lib,
  fetchurl,
  unzip,
  autoPatchelfHook,
  pciutils,
}:
stdenv.mkDerivation rec {
  pname = "bnxtnvm";
  version = "222.0.144.0";
  src = fetchurl {
    url = "https://www.thomas-krenn.com/redx/tools/mb_download.php/ct.YuuHGw/mid.y9b3b4ba2bf7ab3b8/bnxtnvm.zip";
    sha256 = "0aryj1zxbmknj3isd0w1lf5q87y35g3sv7pdrj4lzmbg6d1b9w63";
  };
  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];
  buildInputs = [ pciutils ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bnxtnvm $out/bin/bnxtnvm

    runHook postInstall
  '';

  meta = {
    mainProgram = "bnxtnvm";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Broadcom BNXTNVM utility";
    license = lib.licenses.unfree;
  };
}
