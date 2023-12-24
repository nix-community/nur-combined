{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, fetchpatch
, setuptools
, python3
}:
buildPythonPackage rec {
  name = "penelope";
  owner = "brightio";
  version = "0.10.0";
  #owner = "jpts";
  commit = "83a68680ca91fe813af5cf3a2006c96c15cb070f";
  repo = name;
  format = "pyproject";

  src = fetchFromGitHub {
    inherit owner repo;
    #rev = "refs/tags/v${version}";
    rev = commit;
    sha256 = "sha256-r8ZMwPAKLITHDDafiXb/fE+H8sJnQUgUtbjwQbMko7E=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  # We are a script, no tests
  doCheck = false;
  pythonImportsCheck = [ "penelope" ];

  meta = {
    homepage = "https://github.com/brightio/penelope";
    changelog = "https://github.com/brightio/penelope/tag/v${version}";
    description = "Reverse Shell Handler";
    longDescription = ''
      Penelope is a shell handler designed to be easy to use and intended to replace netcat when exploiting RCE vulnerabilities.
    '';
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jpts ];
    platforms = lib.platforms.unix;
  };
}
