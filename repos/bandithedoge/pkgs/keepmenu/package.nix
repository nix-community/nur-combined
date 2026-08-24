{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "keepmenu";
  version = "1.5.1-unstable-2026-08-14";
  src = fetchFromGitHub {
    owner = "firecat53";
    repo = "keepmenu";
    rev = "5a26ef63f18cdd7e99eca5910fbc80d89684b68e";
    hash = "sha256-KsUc2lXCbi6wFbH6/Tgm8VQu+yDW2NtaGPg7lxQVQ0g=";
  };

  format = "pyproject";

  propagatedBuildInputs = with python3Packages; [
    hatch-vcs
    hatchling
    pykeepass
    pynput
  ];

  doCheck = false;

  passthru = {
    _ignoreDupe = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch"
      ];
    };
  };

  meta = {
    description = "Dmenu/Rofi frontend for Keepass databases";
    homepage = "https://github.com/firecat53/keepmenu";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    broken = true;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
