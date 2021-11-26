{ python3Packages, fetchFromGitHub, i3ipc-glib, python39Packages, lib }:

python3Packages.buildPythonPackage rec {
  pname = "swallow";
  version = "1.1.1";

  rev = "7a9faed693b0da7df762a095fed512eca8c6414c";
  src = fetchFromGitHub {
    owner = "jamesofarrell";
    repo = "i3-swallow";
    rev = "7a9faed";
    sha256 = "bUWmH606sGsP+j45nZg60j+eKI1zhcSQ+v7VqONmCbs=";
  };

  propagatedBuildInputs = [
    i3ipc-glib
    python39Packages.i3ipc
  ];
  configurePhase = ''
    echo 'nothing to configure'
  '';
  setuptoolsCheckPhase = "echo 'nothing to check'";

  buildPhase = ''
    mv swallow.py swallow
    chmod +x swallow
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv swallow $out/bin
  '';
  meta = with lib; {
    description = "Used to swallow a terminal window in i3";
    homepage = "https://github.com/jamesofarrell/i3-swallow";
    license = with licenses; [ gpl2Only ];
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ uniquepointer ];
  };
}
