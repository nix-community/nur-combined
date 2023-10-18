{ bash, fetchFromGitHub, lib, resholve, coreutils, git, gum, gnused, gnugrep }:

resholve.mkDerivation rec {
  pname = "git-polite";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "MikaelFangel";
    repo = "AwesomeScripts";
    rev = "d96e73bc494b3b850fd68b40ae0f935b94211db1";
    hash = "sha256-E+XOkpTg77TiM6a6S1bNeSCW/FXVkH+v1IBycSePH8g=";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm 755 "git-polite" "$out/bin/git-polite"
  '';

  solutions.default = {
    scripts = [ "bin/git-polite" ];
    interpreter = "${bash}/bin/bash";
    inputs = [ coreutils git gnused gnugrep gum ];
    fix.aliases = true;
    execer = [ "cannot:${git}/bin/git" "cannot:${gum}/bin/gum" ];
  };

  meta = with lib; {
    description = "A tool to create github co-author messages.";
    homepage = "https://github.com/MikaelFangel/AwesomeScripts";
    maintainers = with maintainers; [ mikaelfangel ];
    license = licenses.mit;
    mainProgram = "git-polite";
  };
}
