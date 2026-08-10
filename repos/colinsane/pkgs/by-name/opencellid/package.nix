{
  _experimental-update-script-combinators,
  curl,
  fetchFromGitea,
  git,
  gzip,
  lib,
  nix-update-script,
  stdenvNoCC,
  update-guard,
  writeShellApplication,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencellid";
  version = "0-unstable-2026-08-08";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "opencellid-mirror";
    rev = "e3cc72df746f2cf2ca415a98a872c859040ef189";
    hash = "sha256-t4v6Nr3M8Qu2TI6Y3FERBHNul3ZxPbUkp7bmh8BXa9I=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/opencellid
    cp cell_towers.csv $out/share/opencellid

    runHook postInstall
  '';

  passthru = {
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
    updateFromOpenCellId = lib.getExe finalAttrs.passthru.opencellid-update-script;
    updateScript = _experimental-update-script-combinators.sequence [
      update-guard.weekly
      finalAttrs.passthru.updateFromOpenCellId
      finalAttrs.passthru.updateFromMirror
    ];
  };

  meta = {
    description = "100M-ish csv database of known celltower positions";
    homepage = "https://opencellid.org";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
