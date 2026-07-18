{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  update-guard,
  updater-tools,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-goal";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "v${finalAttrs.version}";
    rootDir = "extensions/pi-goal";
    hash = "sha256-k99XYE5R5ex55dCHUU04AMvyy7MUCJIVzbJhz6bceco=";
    postFetch = ''
      sed -i $out/package.json \
        -e '/"@earendil-works\/pi-coding-agent": /d'
    '';
  };

  npmDepsFetcherVersion = 2;

  npmDepsHash = "sha256-LwbCUI8rB1+dT+FWcUjS/7xMjzmVDd6jrxukhDdr48M=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/@narumitw/pi-goal/* $out
    rmdir $out/lib/node_modules/@narumitw/pi-goal
    rmdir $out/lib/node_modules/@narumitw
    rmdir $out/lib/node_modules/
    rmdir $out/lib
  '';

  passthru.updateScript = updater-tools.requireAll [
    (update-guard.days 3)
    (nix-update-script {
      extraArgs = [
        "--generate-lockfile"
      ];
    })
  ];

  meta = {
    description = "Pi extension that keeps working on a /goal until the agent marks it complete";
    homepage = "https://pi.dev/packages/@narumitw/pi-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
