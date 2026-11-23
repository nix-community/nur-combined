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
    rev = "1a2ebc6a8133cfdafb98cc7fcdd209878acf04bf";
    sha256 = "sha256-Jk/8ApQg0sYFUC8ZVR+6HtvEi9qbGMvtW9bUBND5vkw=";
  };

  updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
      "--override-filename"
      "pkgs/fira-code/package.nix"
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
    inherit (pkgs.python3Packages) fontmake gftools;
  }
else
  pkgs.callPackage ./ttf.nix {
    inherit meta src updateScript;
    inherit (pkgs.python3Packages) fontmake;
  }
