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
    rev = "727682c24c33fb0bbc7ab0ed9b7a8d0d9745a198";
    sha256 = "sha256-2/64g+J9l3XVcYJ2yRsrY5jnQzU+OT6Madl97mCzTuk=";
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
