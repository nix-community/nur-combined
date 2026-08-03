{
  lib,
  pkgs,
  fetchFromGitHub,
  useVariableFont ? true,
  nix-update-script,
}:

let
  src = fetchFromGitHub {
    owner = "tonsky";
    repo = "FiraCode";
    rev = "ecd367b040ad92a28b64fa93135775f7e2417b37";
    sha256 = "sha256-jjV+63PCxCxzMjur2x/MVOfNUMJEFnG+8Zl6NSri1VA=";
  };

  updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
      "--override-filename"
      "pkgs/fira-code/default.nix"
    ];
  };

  meta = {
    description = "Monospaced font with programming ligatures";
    homepage = "https://github.com/tonsky/FiraCode";
    license = lib.licenses.ofl;
  };

in
if useVariableFont then
  pkgs.callPackage ./vf.nix {
    inherit meta src updateScript;
  }
else
  pkgs.callPackage ./ttf.nix {
    inherit meta src updateScript;
  }
