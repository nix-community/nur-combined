{
  lib,
  stdenv,
  steamacSrc,
  git,
  cacert,
  python3,
}:

# host/virglrenderer/build.sh merges upstream virglrenderer main into UTM's
# macos-next fork with git (five conflicts resolved by merge-resolve.py), then
# applies the Steamac patch series. The histories and network access are only
# available during a fixed-output fetch, so reproduce that source preparation
# here and pin the resulting tree.
stdenv.mkDerivation {
  name = "virglrenderer-steamac-src";

  nativeBuildInputs = [
    git
    cacert
    python3
  ];

  dontUnpack = true;
  dontConfigure = true;
  # The tree contains helper scripts whose shebangs must stay untouched: a
  # fixed-output derivation may not reference store paths.
  dontFixup = true;

  __noChroot = true;
  impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
    "GIT_CONFIG_GLOBAL"
    "GIT_CONFIG_SYSTEM"
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR
    export GIT_SSL_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt
    export GIT_AUTHOR_NAME=steamac GIT_AUTHOR_EMAIL=steamac@local
    export GIT_COMMITTER_NAME=steamac GIT_COMMITTER_EMAIL=steamac@local
    export GIT_AUTHOR_DATE=2026-10-03T00:00:00Z GIT_COMMITTER_DATE=2026-10-03T00:00:00Z

    git init -q src
    git -C src remote add origin https://github.com/utmapp/virglrenderer.git
    git -C src fetch -q origin 5d26f605f50f8e22002ec6db5fb775e1992d4e96
    git -C src fetch -q https://gitlab.freedesktop.org/virgl/virglrenderer.git \
      aafa9bd234a43c31004ec768ce000b21cf7b99ca
    git -C src checkout -q -f --detach 5d26f605f50f8e22002ec6db5fb775e1992d4e96

    if ! git -C src merge -q --no-ff --no-edit aafa9bd234a43c31004ec768ce000b21cf7b99ca > /dev/null 2>&1; then
      (cd src && python3 ${steamacSrc}/host/virglrenderer/merge-resolve.py)
      git -C src commit -q --no-edit
    fi
    if git -C src grep -qE '^(<<<<<<<|>>>>>>>) ' -- '*.c' '*.h' '*.build'; then
      echo "unresolved merge conflict markers" >&2
      exit 1
    fi
    for p in ${steamacSrc}/host/virglrenderer/patches/*.patch; do
      echo ">> applying $(basename "$p")"
      git -C src apply --whitespace=nowarn "$p"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R src/. "$out"/
    rm -rf "$out/.git"
    runHook postInstall
  '';

  outputHashMode = "recursive";
  outputHash = "sha256-fBoQue0fqcwWAPNNdv9Tt9ZiCJGzo7NfraF2Fj3zAlY=";

  meta = {
    description = "Steamac's merged virglrenderer source tree";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
  };
}
