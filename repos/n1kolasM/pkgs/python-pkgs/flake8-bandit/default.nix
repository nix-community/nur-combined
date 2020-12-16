{ stdenv, buildPythonPackage, fetchFromGitHub, flake8
, bandit, flake8-polyfill, pycodestyle, pytest }:
buildPythonPackage rec {
  pname = "flake8-bandit";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "tylerwince";
    repo = pname;
    rev = "f0fe747258abd9fc3ce471cdcf55ece7424298ef";
    sha256 = "1wxcda9779d5cnld1qw4sfp53admnr403sm6a88l64anbw6dm64m";
  };

  propagatedBuildInputs = [ flake8 bandit flake8-polyfill pycodestyle ];

  checkInputs = [ pytest ];
  checkPhase = ''
    ${pytest}/bin/pytest
  '';

  meta = with stdenv.lib; {
    broken = true;
    description = "Automated security testing with bandit and flake8.";
    homepage = https://github.com/tylerwince/flake8-bandit;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}

