{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "isotp-c";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "SimonCahill";
    repo = "isotp-c";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cu4BPPu/nHyTpJQuIN0jpwzQeyn/Ryfe59dbYs8DGd0=";
  };

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    install -Dm644 $src/*.h -t $out/include
    install -Dm644 libisotp.so -t $out/lib
  '';

  meta = {
    description = "An implementation of the ISO-TP (ISO15765-2) CAN protocol in C";
    homepage = "https://github.com/SimonCahill/isotp-c";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
