{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  lib,
  moreutils,
  nix-update-script,
  update-guard,
  updater-tools,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-goal";
  version = "0.40.0";

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "v${finalAttrs.version}";
    rootDir = "extensions/pi-goal";
    hash = "sha256-xGTTfzF7DfvQwtj951oaS626Ed/WmPthZPZLJuEx5eI=";
    postFetch = ''
      jq '
        del(
          .dependencies["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"],
          .devDependencies["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"],
          .peerDependencies["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"],
          .peerDependenciesMeta["@earendil-works/pi-ai", "@earendil-works/pi-tui", "@earendil-works/pi-coding-agent"]
        )
      ' $out/package.json | sponge $out/package.json
    '';
    nativeBuildInputs = [
      jq
      moreutils
    ];
  };

  npmFlags = [ "--legacy-peer-deps" ];

  npmDepsHash = "sha256-uwDjk71I0f6edlQHpwsELvhXjc9c3yN4WSXGvVd8c3I=";

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
