{
  _experimental-update-script-combinators,
  curl,
  fetchFromGitea,
  git,
  gzip,
  lib,
  nix-update-script,
  stdenv,
  writeShellApplication,
}:

stdenv.mkDerivation {
  pname = "opencellid";
  version = "0-unstable-2025-04-01";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "opencellid-mirror";
    rev = "b87c0238188f500af2d1a7103e859d17d7855778";
    hash = "sha256-OHlDRGRtmNw0K8mW+H7j2Fqk1p5xFuilR+ykpONAnLA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp cell_towers.csv $out

    runHook postInstall
  '';

  passthru = rec {
    updateFromMirror = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
    opencellid-update-script = writeShellApplication {
      name = "opencellid-update-script";
      runtimeInputs = [ curl git gzip ];
      text = ''
        set -x
        pushd "$(mktemp -d opencellid.XXXXXXXX --tmpdir)"

        git clone git@git.uninsane.org:colin/opencellid-mirror.git
        cd opencellid-mirror
        ./update

        # with `git gc` a daily commit is compressed from ~160MB -> 4-8MB (as measured by the reported size of .git dir).
        # not sure if this affects the size when pushed to the remote though.
        git gc
        git push origin master

        popd
      '';
    };
    updateFromOpenCellId = lib.getExe opencellid-update-script;
    updateScript = _experimental-update-script-combinators.sequence [
      updateFromOpenCellId
      updateFromMirror
    ];
  };

  meta = with lib; {
    description = "100M-ish csv database of known celltower positions";
    homepage = "https://opencellid.org";
    maintainers = with maintainers; [ colinsane ];
  };
}
