{
  lib,
  stdenv,
  fetchFromGitLab,
  python3,
}: let
  rev = "0483c85b93362637bdd0632056ff986c07f30868";
  hash = "sha256-rj0qKYHCu9SyNsj1PZn1g7arjcHuIDGHwubZg/yJt7A=";
in
  stdenv.mkDerivation rec {
    pname = "pokemon-colorscripts";
    version = builtins.substring 0 8 rev;

    src = fetchFromGitLab {
      owner = "phoneybadger";
      repo = "pokemon-colorscripts";
      inherit rev hash;
    };

    buildInputs = [python3];

    preBuild = ''
      patchShebangs ./install.sh
      patchShebangs ./pokemon-colorscripts.py

      substituteInPlace install.sh --replace "/usr/local" "$out"
    '';

    installPhase = ''
      mkdir -p $out/bin
      ./install.sh
    '';

    meta = {
      homepage = "https://gitlab.com/phoneybadger/pokemon-colorscripts";
      description = "CLI utility to print out images of pokemon to terminal";
      longDescription = ''
        Prints out colored unicode sprites of pokemon onto your terminal.
        Contains almost 900 pokemon from gen 1 to gen 8.
      '';
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  }
