{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
  jq,
  nix-update-script,
}:

buildNpmPackage (final: {
  pname = "chrome-devtools-mcp";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "ChromeDevTools";
    repo = "chrome-devtools-mcp";
    rev = "chrome-devtools-mcp-v${final.version}";
    hash = "sha256-3H858tro0VGawNrINf1FGtLRWsOISq2GK+eLTCqGUTg=";
    fetchSubmodules = true;
  };

  # upstream doesn't always keep `resolved` in package-lock.json, which makes
  # fetchNpmDeps skip those packages. derive the registry tarball url for any
  # registry package that is missing one. postPatch is shared with fetchNpmDeps
  # https://github.com/ChromeDevTools/chrome-devtools-mcp/issues/3219
  postPatch = ''
    ${lib.getExe jq} '
      .packages |= with_entries(
        if (.key | contains("node_modules/"))
          and .value.resolved == null
          and .value.integrity != null
          and (.value.link | not)
          and (.value.inBundle | not)
        then
          (.value.name // (.key | sub("^.*node_modules/"; ""))) as $name
          | .value.resolved = "https://registry.npmjs.org/\($name)/-/\($name | sub("^@[^/]+/"; ""))-\(.value.version).tgz"
        else . end
      )
    ' package-lock.json > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json
  '';

  npmDepsHash = "sha256-CEYtrmCDO+EeKoScH8IO+jsJCrkvzJKqqeoT+yqD1FU=";

  postConfigure = ''
    npm run prepare
  '';

  npmBuildScript = "bundle";
  PUPPETEER_SKIP_DOWNLOAD = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex='chrome-devtools-mcp-v(.*)'"
      "--commit"
      final.pname
    ];
  };

  meta = {
    mainProgram = "chrome-devtools-mcp";
    description = "Chrome DevTools for coding agents";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
    changelog = "https://github.com/ChromeDevTools/chrome-devtools-mcp/releases/tag/v${final.version}";
  };
})
