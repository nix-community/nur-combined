{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "xonsh-direnv";
  version = "1.7.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "greg-hellings";
    repo = "xonsh-direnv";
    rev = version;
    hash = "sha256-LPSYUK07TQuTI+u0EmUuGL48znUfRDVGEIS/mmzcETU=";
  };

  postPatch = ''
    substituteInPlace xontrib/direnv.xsh \
      --replace-fail "\$DIRENV_DIR" "__xonsh__.env['DIRENV_DIR']"
  '';

  meta = with lib; {
    description = "Direnv support for the xonsh shell";
    homepage = "https://github.com/greg-hellings/xonsh-direnv";
    license = licenses.mit;
  };
}
