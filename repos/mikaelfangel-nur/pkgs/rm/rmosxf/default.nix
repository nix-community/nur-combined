{ bash, fetchFromGitHub, lib, resholve, findutils, coreutils }:

resholve.mkDerivation rec {
  pname = "rmosxf";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "MikaelFangel";
    repo = "AwesomeScripts";
    rev = "be0a3f5554a3449b9a0975cdf8c321589f8d35cd";
    hash = "sha256-7X6KA3i7V0iIrK4UPwx90tKCyzBR/w2RkZiP030Hda0=";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm 755 rmosxf.sh $out/bin/rmosxf
  '';

  solutions.default = {
    scripts = [ "bin/rmosxf" ];
    interpreter = "${bash}/bin/sh";
    inputs = [ findutils coreutils ];
    fix.aliases = true;
  };

  meta = with lib; {
    description = "A tool to remove osx file from the system";
    homepage = "https://github.com/MikaelFangel/AwesomeScripts";
    maintainers = with maintainers; [ mikaelfangel ];
    license = licenses.mit;
    mainProgram = "rmosxf";
  };
}
