{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:
stdenv.mkDerivation rec {
  pname = "cpond";
  version = "0-unstable-2025-11-23";

  src = fetchFromGitHub {
    owner = "ayuzur";
    repo = pname;
    rev = "b6d2827c73080b144ff07a70ec61757baff6a73b";
    hash = "sha256-feRGJ2CIa82eEiGG65WwFlh6dhhIvhW70FJMObWvi1Q=";
  };

  buildInputs = [ncurses];

  installPhase = ''
    runHook preInstall

    install -Dm755 cpond $out/bin/cpond

    runHook postInstall
  '';

  meta = with lib; {
    description = "Procedurally animated fish for your terminal";
    homepage = "https://github.com/ayuzur/cpond";
    license = licenses.mit;
    mainProgram = "cpond";
  };
}
