{
  _experimental-update-script-combinators,
  curl,
  fetchFromGitea,
  git,
  gnutar,
  lib,
  nix-update-script,
  sqlite,
  stdenvNoCC,
  writeShellApplication,
}:

stdenvNoCC.mkDerivation {
  pname = "podcastindex-db";
  version = "0-unstable-2025-08-03";

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "podcastindex-db-mirror";
    rev = "745f921132cb70f703778864f6eea7be08781995";
    hash = "sha256-10xZgByev1DkrPL+4A27Kr61VcQ1fJZ295dbfJSefws=";
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
