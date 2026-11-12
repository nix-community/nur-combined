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
  version = "0-unstable-2026-11-04";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "opencellid-mirror";
    rev = "966e5e8d0c2a2fd542d3452dad8087bbe895f5cf";
    hash = "sha256-8698TLKK4tQYZzRDsGmHOOPDrfxnqrSRu1TTwhk+fqE=";
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
