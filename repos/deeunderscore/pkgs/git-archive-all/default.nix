{ stdenv, lib, pkgs, python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication  rec {
  pname = "git-archive-all";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "Kentzo";
    repo = "git-archive-all";
    rev =  version;
    sha256 = "sha256-G1xaZ/71omLnl7eVRIzIwB6n5MqJgWXZuh+z/ZDYSeY=";
  };

  preCheck = ''
    substituteInPlace setup.cfg --replace 'pytest-mock==1.11.2' 'pytest-mock'
    substituteInPlace setup.cfg --replace 'pytest-cov==2.8.1' 'pytest-cov'
    substituteInPlace setup.cfg --replace 'pytest==5.2.2' 'pytest'
    substituteInPlace setup.cfg --replace 'pycodestyle==2.5.0' 'pycodestyle'
  '';

  # most tests fail with "ResourceWarning: unclosed file" with pytest >5
  doCheck = false;

  meta = {
    description = "A wrapper for git-archive which exports git repos together with their submodules";
    homepage = "https://github.com/Kentzo/git-archive-all";
    license = lib.licenses.mit;
  };
}
