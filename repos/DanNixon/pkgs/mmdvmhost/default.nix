{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libsamplerate,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mmdvmhost";
  version = "2024-02-09";

  src = fetchFromGitHub {
    owner = "g4klx";
    repo = "MMDVMHost";
    rev = "218a017956b174334a2fe0418e373ba139768f5f";
    sha256 = "+aji55IeWx2CLiedEnruNMcOF6ADPQoPyhA/sGS34Z4=";
  };

  patches = [
    ./798.patch
  ];

  buildInputs = [
    libsamplerate
  ];

  installPhase = ''
    install -Dm775 MMDVMHost $out/bin/MMDVMHost
    install -Dm775 RemoteCommand $out/bin/RemoteCommand
  '';

  meta = {
    description = "The host program for the MMDVM";
    homepage = "https://github.com/g4klx/MMDVMHost";
    platforms = lib.platforms.unix;
    license = lib.licenses.gpl2;
  };
})
