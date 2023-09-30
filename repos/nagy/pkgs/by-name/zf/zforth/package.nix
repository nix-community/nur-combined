{ lib, stdenv, fetchFromGitHub, readline }:

stdenv.mkDerivation {
  pname = "zforth";
  version = "unstable-2023-06-10";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "zForth";
    rev = "b33fa29be37b84f8293625df4d732e4cacca56a1";
    hash = "sha256-rISj2c+Lt9eIDUmeh6Q0aVGWpxXNGU9bPJUKu/gY75c=";
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
