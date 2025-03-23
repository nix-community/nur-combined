{ lib, stdenv, fetchFromGitHub, readline }:

stdenv.mkDerivation {
  pname = "zforth";
  version = "0-unstable-2025-02-14";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "zForth";
    rev = "957f08668362cdf78fac939bcfcd6d09af441bed";
    hash = "sha256-lr3+YdQ9C6ZI4q1QZbCKmq2q7/+UTCjrR6CF/+yPTuM=";
  };

  buildInputs = [ readline ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin src/linux/zforth
    install -Dm644 -t $out/share/zforth/ forth/*

    runHook postInstall
  '';

  meta = {
    description =
      "tiny, embeddable, flexible, compact Forth scripting language for embedded systems";
    homepage = "https://github.com/zevv/zForth";
    license = with lib.licenses; [ mit ];
    mainProgram = "zforth";
  };
}
