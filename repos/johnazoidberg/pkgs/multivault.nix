{ stdenv, fetchFromGitHub, python3Packages, python3, myPython3Packages }:
python3Packages.buildPythonApplication rec {
  name = "multivault-${version}";
  version = "2018-09-19";

  src = fetchFromGitHub {
    owner = "Selfnet";
    repo = "multivault";
    rev = "26c1dc7880f7af0c510511cb7cafb9b5a8150a93";
    sha256 = "19xdplif1dr5gg27xz6ml07vqm32nyh1b6akqnaczf46ccn0r13q";
  };

  propagatedBuildInputs = with python3Packages; [
    pyyaml ldap3 paramiko requests voluptuous
  ] ++ [ myPython3Packages.hkp4py ];

  doCheck = false;  # Requires multivault.yml in /etc/ or /homeless-shelter

  checkInputs = with python3Packages; [ pylint autopep8 pep8 ];

  preInstall = ''
    # See https://github.com/NixOS/nixpkgs/issues/4968
    ${python3}/bin/${python3.executable} setup.py install_data --install-dir=$out --root=$out
  '';

  meta = with stdenv.lib; {
    description = "Simple CLI to manage distributed secrets for Ansible";
    license = licenses.mit;
    homepage = https://github.com/Selfnet/multivault;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

