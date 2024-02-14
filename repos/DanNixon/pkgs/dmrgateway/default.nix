{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dmrgateway";
  version = "2024-02-02";

  src = fetchFromGitHub {
    owner = "g4klx";
    repo = "DMRGateway";
    rev = "2b81fe225b59ea123d21ff167406546ead0d57c2";
    sha256 = "p6sGPWuRWQ0UfW6aUHt1omR88k8ZtrKhVoO+Dvay2T4=";
  };

  installPhase = ''
    install -Dm775 DMRGateway $out/bin/DMRGateway
  '';

  meta = {
    description = "A multi-network DMR gateway for the MMDVM";
    homepage = "https://github.com/g4klx/DMRGateway";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl2;
  };
})
