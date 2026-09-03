{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-web-access";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-web-access";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q7o4PMNr2zZR+UXjL9ZGMuedehJEYayuoSH03QBBB68=";
  };

  # Pi provides these peers at runtime, but their nested lock entries have no
  # integrity hashes for buildNpmPackage to fetch.
  postPatch = ''
    ${lib.getExe jq} '
      del(
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-agent-core"],
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-ai"],
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-client"],
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-protocol"],
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-telemetry"],
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui"]
      )
    ' package-lock.json > package-lock.patched.json
    mv package-lock.patched.json package-lock.json
  '';

  npmDepsHash = "sha256-QROgrojfl20t8mM3RjFgq7JoYmC6/k2fD5Gt7/Zmajw=";

  npmFlags = [
    "--ignore-scripts"
    "--omit=dev"
    "--omit=peer"
  ];
  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -rL --no-preserve=mode *.ts package.json node_modules "$out/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    layout =
      runCommand "test-pi-web-access-layout"
        {
          nativeBuildInputs = [ jq ];
        }
        ''
          test -s ${finalAttrs.finalPackage}/index.ts
          test -s ${finalAttrs.finalPackage}/node_modules/undici/package.json
          test ! -e ${finalAttrs.finalPackage}/node_modules/@earendil-works
          jq --exit-status --arg version "${finalAttrs.version}" '
            .name == "pi-web-access"
            and .version == $version
            and .pi.extensions == ["./index.ts"]
          ' ${finalAttrs.finalPackage}/package.json >/dev/null
          touch $out
        '';
  };

  meta = {
    description = "Web search and content extraction for the Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-web-access";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
