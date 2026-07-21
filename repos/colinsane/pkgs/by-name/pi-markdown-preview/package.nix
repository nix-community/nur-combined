{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pandoc,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mtAwvOYlYA7Wd55ID6XIhWvz7css0CPMABOowksYS3o=";
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-PRrWHl2z8XP2zOE0MAp21c1XzwdcagItjvPDp1c1X+c=";

  # build the lock file ourselves, otherwise buildNpmPackage fails:
  # > non-git dependencies should have associated integrity
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  propagatedBuildInputs = [
    pandoc
  ];

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-markdown-preview/* $out
    rmdir $out/lib/node_modules/pi-markdown-preview
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };
  passthru.skipBulkUpdate = true;  #< patched lockfile generation is not automated, breaks

  meta = {
    description = "Rendered markdown + LaTeX preview for pi, with terminal, browser, and PDF output";
    homepage = "https://github.com/omaclaren/pi-markdown-preview";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
