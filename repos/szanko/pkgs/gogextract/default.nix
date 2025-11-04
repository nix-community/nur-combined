{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper
}:

python3.pkgs.buildPythonApplication {
  pname = "gogextract";
  version = "unstable-2016-10-09";

  src = fetchFromGitHub {
    owner = "Yepoleb";
    repo = "gogextract";
    rev = "6601b32feacecd18bc12f0a4c23a063c3545a095";
    hash = "sha256-BTtm3Tn2hFS512w+IcJQfGKSgi2dpYLg1VxNXRODBEI=";
  };

  format = "other";

  nativeBuildInputs = [ 
    makeWrapper 
  ];
  dontBuild = true;
  installPhase = ''
    install -Dm0755 gogextract.py $out/bin/gogextract
    patchShebangs $out/bin/gogextract
  '';

  meta = {
    description = "Script for unpacking GOG Linux installers";
    homepage = "https://github.com/Yepoleb/gogextract/tree/master";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "gogextract";
    platforms = lib.platforms.all;
  };
}
