{
  lib,
  fetchzip,
  stdenvNoCC,
  perl,
  makeWrapper,
  git,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pool-git-init";
  version = "0.3.1";
  strictDeps = true;
  __structuredAttrs = true;

  # fetchFromGitea's /archive/ URL is behind a JS bot challenge (HTTP 403),
  # but the equivalent API endpoint is not.
  src = fetchzip {
    url = "https://src.opensuse.org/api/v1/repos/openSUSE/pool-git-init/archive/${finalAttrs.version}.tar.gz";
    hash = "sha256-pY6x0HqaWw2Cm5luzQvLZwQlMBm22gcuXkV0okvKQb4=";
  };

  postPatch = ''
    substituteInPlace pool-git-init merge-git-modules \
      --replace-fail /usr/lib/pool/helper "$out/lib/pool/helper"
    # Upstream's tests reference the author's checkout in a few places.
    substituteInPlace test/test_merge_gitmodules.sh \
      --replace-fail /opencode/obs-git-init/merge-git-modules '"$TOOL"'
    patchShebangs --build bs_mergechanges merge-git-modules prepare-commit-message test
  '';

  nativeBuildInputs = [
    makeWrapper
    finalAttrs.passthru.perl
  ];

  buildInputs = [ finalAttrs.passthru.perl ];

  # The Makefile's only target is `install`.
  dontBuild = true;

  makeFlags = [ "prefix=${placeholder "out"}" ];

  postInstall = ''
    rmdir $out/lib/obs
    wrapProgram $out/bin/pool-git-init \
      --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  doCheck = true;
  nativeCheckInputs = [ git ];
  checkPhase = ''
    runHook preCheck

    export HOME=$(mktemp -d)
    git config --global init.defaultBranch main
    bash test/run_all.sh

    runHook postCheck
  '';

  passthru = {
    perl = perl.withPackages (ps: [
      ps.ConfigIniFiles
      ps.TimeDate
    ]);
    updateScript = nix-update-script {
      extraArgs = [
        "--url"
        finalAttrs.meta.homepage
      ];
    };
  };

  meta = {
    description = "Initialize and manage git repositories used for openSUSE packaging";
    homepage = "https://src.opensuse.org/openSUSE/pool-git-init";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "pool-git-init";
    platforms = lib.platforms.unix;
  };
})
