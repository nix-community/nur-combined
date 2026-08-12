{ stdenv, bash, fetchFromGitHub, lib, makeWrapper, coreutils, git, gum, gnused, gnugrep }:

stdenv.mkDerivation rec {
  pname = "git-polite";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "MikaelFangel";
    repo = "AwesomeScripts";
    rev = "d96e73bc494b3b850fd68b40ae0f935b94211db1";
    hash = "sha256-E+XOkpTg77TiM6a6S1bNeSCW/FXVkH+v1IBycSePH8g=";
  };

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ coreutils git gnused gnugrep gum ];

  installPhase = ''
    runHook preInstall

    install -Dm 755 "git-polite" "$out/bin/git-polite"

    runHook postInstall
  '';


  postFixup = ''
    wrapProgram "$out/bin/git-polite" \
      --prefix PATH : ${lib.makeBinPath buildInputs };
  '';

  meta = with lib; {
    description = "A tool to create github co-author messages.";
    homepage = "https://github.com/MikaelFangel/AwesomeScripts";
    maintainers = with maintainers; [ mikaelfangel ];
    license = licenses.mit;
    mainProgram = "git-polite";
  };
}
