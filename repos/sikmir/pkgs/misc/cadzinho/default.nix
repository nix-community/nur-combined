{ lib, stdenv, fetchFromGitHub, SDL2, glew, lua, desktopToDarwinBundle }:

stdenv.mkDerivation rec {
  pname = "cadzinho";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "zecruel";
    repo = "CadZinho";
    rev = version;
    hash = "sha256-ple9Tl2thfXgW8+HtaUTAvRhkXLYTz2qx2PTAcvLI7o=";
  };

  postPatch = ''
    substituteInPlace src/gui_config.c --replace "/usr/share/cadzinho" "$out/share/cadzinho"
  '';

  nativeBuildInputs = lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [ SDL2 glew lua ];

  makeFlags = [ "CC:=$(CC)" ];

  NIX_CFLAGS_COMPILE = "-Wno-format-security";

  installPhase = ''
    runHook preInstall
    install -Dm755 cadzinho -t $out/bin
    install -Dm644 lang/*.lua -t $out/share/cadzinho/lang
    cp -r linux/CadZinho/share/* $out/share
    runHook postInstall
  '';

  meta = with lib; {
    description = "Minimalist computer aided design (CAD) software";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    mainProgram = "cadzinho";
  };
}
