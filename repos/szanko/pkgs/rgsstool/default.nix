{
  lib,
  python3,
  fetchFromGitLab,
  makeWrapper
}:

python3.pkgs.buildPythonApplication {
  pname = "rgsstool";
  version = "unstable-2020-08-13";

  src = fetchFromGitLab {
    owner = "rgss";
    repo = "rgsstool";
    rev = "5396d8741eb434e45f933961953d9e4e16385d01";
    hash = "sha256-z34iP3tLg00MoyGcwSDCXd0a87BzJ/TRNAo3ihnuVkw=";
  };
  format = "other";
  nativeBuildInputs = [ 
    makeWrapper 
  ];
  dontBuild = true;
  installPhase = ''
    install -Dm0644 rgsstool.py $out/libexec/rgsstool.py
    makeWrapper ${python3.interpreter} $out/bin/rgsstool \
      --add-flags $out/libexec/rgsstool.py
  '';


  meta = {
    description = "Tool to create and extract files from RPG Maker archives";
    homepage = "https://gitlab.com/rgss/rgsstool";
    license = lib.licenses.gpl3Only;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "rgsstool";
    platforms = lib.platforms.all;
  };
}
