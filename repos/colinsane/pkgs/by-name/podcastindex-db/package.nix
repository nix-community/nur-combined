{
  _experimental-update-script-combinators,
  curl,
  fetchFromGitea,
  # fetchurl,
  git,
  gnutar,
  lib,
  nix-update-script,
  sqlite,
  stdenvNoCC,
  writeShellApplication,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "podcastindex-db";
  version = "0-unstable-2026-04-29";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "podcastindex-db-mirror";
    forceFetchGit = true;  #< XXX(2026-03-27): else the archive .tar.gz as returned by gitea may be truncated.
    rev = "67711664e896bc3f01e28dd83d63daa8f6bdae65";
    hash = "sha256-heW/Z3MEoW/5bv9qUSVlEGBGuV4nSCwoJrsx84qTH40=";
  };

  # src = fetchurl {
  #   # N.B.: updateScript needs fixing or at least checking, for this to work.
  #   # `unstableGitUpdater { url = "https://git.uninsane.org/colin/podcastindex-db-mirro"; }` should support this.
  #   url = "https://git.uninsane.org/colin/podcastindex-db-mirror/raw/commit/${commit}/podcastindex_feeds.csv";
  #   hash = "${hash}";
  # };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/podcastindex
    cp podcastindex_feeds.csv $out/share/podcastindex

    runHook postInstall
  '';

  passthru = {
    updateNixFromMirror = nix-update-script {
      extraArgs = [ "--version" "branch" ];
    };
    mirror-update-script = writeShellApplication {
      name = "mirror-update-script";
      runtimeInputs = [
        curl
        git
        gnutar
        sqlite
      ];
      text = ''
        set -ex
        CHECKOUT_DIR=$(mktemp -d podcastindex.XXXXXXXX --tmpdir)
        pushd "$CHECKOUT_DIR"

        git clone --depth 1 git@git.uninsane.org:colin/podcastindex-db-mirror.git
        cd podcastindex-db-mirror
        ./update

        git push origin master

        popd
        rm -rf "$CHECKOUT_DIR"
      '';
    };
    updateMirrorFromUpstream = lib.getExe finalAttrs.passthru.mirror-update-script;
    updateScript = _experimental-update-script-combinators.sequence [
      finalAttrs.passthru.updateMirrorFromUpstream
      finalAttrs.passthru.updateNixFromMirror
    ];
  };

  meta = {
    description = "csv database of 800k+ known public podcasts";
    homepage = "https://podcastindex.org";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
