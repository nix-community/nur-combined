{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  direnv,
  setuptools,
}:
buildPythonPackage rec {
  pname = "xontrib-xonsh-direnv";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "74th";
    repo = "xonsh-direnv";
    rev = "3bea5847b9459c5799c64966ec85e624d0be69b9";
    sha256 = "sha256-h56Gx/MMCW4L6nGwLAhBkiR7bX+qfFk80LEsJMiDtjQ=";
  };

  prePatch = ''
    substituteInPlace xontrib/direnv.xsh \
      --replace '__direnv_post_rc()' \
                '__direnv_post_rc(**kwargs)' \
      --replace '__direnv_chdir(olddir: str, newdir: str)' \
                '__direnv_chdir(olddir: str, newdir: str, **kwargs)' \
      --replace '__direnv_postcommand(cmd: str, rtn: int, out: str or None, ts: list)' \
                '__direnv_postcommand(cmd: str, rtn: int, out: str or None, ts: list, **kwargs)'
  '';

  propagatedBuildInputs = [
    direnv
  ];

  nativeBuildInputs = [
    setuptools
  ];

  meta = with lib; {
    description = "Direnv support for Xonsh";
    homepage = "https://github.com/74th/xonsh-direnv/";
    license = licenses.mit;
    maintainers = with maintainers; [greg];
  };
}
