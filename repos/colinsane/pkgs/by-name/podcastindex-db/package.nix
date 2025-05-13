{
  _experimental-update-script-combinators,
  curl,
  fetchFromGitea,
  git,
  gnutar,
  lib,
  nix-update-script,
  sqlite,
  stdenv,
  writeShellApplication,
}:

stdenv.mkDerivation {
  pname = "podcastindex-db";
  version = "0-unstable-2025-05-08";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "podcastindex-db-mirror";
    rev = "36a16784f764b8dfe421839832b62c3ed18ed2ce";
    hash = "sha256-cH62ijVJesXZXoPV2Er3PMK4j2pArORxK+KOSSorMjI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/podcastindex
    cp podcastindex_feeds.csv $out/share/podcastindex

    runHook postInstall
  '';

  passthru = rec {
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
        set -x
        pushd "$(mktemp -d podcastindex.XXXXXXXX --tmpdir)"

        git clone git@git.uninsane.org:colin/podcastindex-db-mirror.git
        cd podcastindex-db-mirror
        ./update

        git push origin master

        popd
      '';
    };
    updateMirrorFromUpstream = lib.getExe mirror-update-script;
    updateScript = _experimental-update-script-combinators.sequence [
      updateMirrorFromUpstream
      updateNixFromMirror
    ];
  };

  meta = with lib; {
    description = "csv database of 800k+ known public podcasts";
    homepage = "https://podcastindex.org";
    maintainers = with maintainers; [ colinsane ];
  };
}
