{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonPackage rec {
  pname = "xonsh-direnv";
  version = "1.6.3";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "74th";
    repo = "xonsh-direnv";
    rev = version;
    hash = "sha256-97c2cuqG0EitDdCM40r2IFOlRMHlKC4cLemJrPcxsZo=";
  };

  meta = with lib; {
    description = "Direnv support for the xonsh shell";
    homepage = "https://github.com/74th/xonsh-direnv";
    license = licenses.mit;
  };
}
