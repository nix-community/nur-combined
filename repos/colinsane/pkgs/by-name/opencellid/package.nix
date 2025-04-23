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
  version = "0-unstable-2025-04-23";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "opencellid-mirror";
    rev = "c7046b0e6db04d9db0c1f8386c2a84eb3b9f83ac";
    hash = "sha256-R2Q+F6EMJleXN5jqv4xCUk0UGgLUH1c23A2NQDc78So=";
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
