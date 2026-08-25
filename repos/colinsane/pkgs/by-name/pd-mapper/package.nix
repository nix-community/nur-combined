{
  fetchFromGitHub,
  lib,
  qrtr,
  stdenv,
  xz,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pd-mapper";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "pd-mapper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I5/N24KONtNRSub00Mqh1GoMHO2qQKTj/ts2N6DQdPc=";
  };

  buildInputs = [
    qrtr
    xz
  ];
  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Qualcomm protection-domain mapper";
    homepage = "https://github.com/linux-msm/pd-mapper";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.aarch64;
    mainProgram = "pd-mapper";
  };
})
