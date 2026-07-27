{ lib
, python3Packages
, fetchFromGitHub 
}:

python3Packages.buildPythonPackage {
  pname = "kitty-ntfy-cmd";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "kitty-ntfy-cmd";
    rev = "58d4115b4c7068753e36d6ff3aaa48ac1c51ffcf";
    sha256 = "sha256-K9eBH8EsYQDpFYJ53qf+alPLEar/HrZtdDfCQhUfKlA=";
  };

  # src = nix-gitignore.gitignoreSource [ ] /home/scott/GIT/kitty-ntfy-cmd;
  propagatedBuildInputs = with python3Packages; [ plyer dbus-python ];
  buildInputs = with python3Packages; [ setuptools ];
  pyproject = true;

  meta = with lib; {
    description = "Python script and kitty watcher to make kitty post ntfy notifications when commands have finished executing";
    homepage = "http://github.com/SCOTT-HAMILTON/kitty-ntfy-cmd";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
