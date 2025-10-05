{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cxxtest,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "subprocess";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "benman64";
    repo = "subprocess";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tgmihv7SJfYpOYHvtuE8rgFzUHyl4bJh9W5CSqotVMg=";
  };

  nativeBuildInputs = [
    cmake
    cxxtest
  ];

  buildInputs = [ python3 ];

  installPhase = ''
    install -Dm644 $src/src/cpp/*.hpp -t $out/include
    install -Dm644 $src/src/cpp/subprocess/*.hpp -t $out/include/subprocess
    install -Dm644 subprocess/libsubprocess.a -t $out/lib
  '';

  meta = {
    description = "Cross platform subprocess library for c++ similar to design of python subprocess";
    homepage = "https://github.com/benman64/subprocess";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
