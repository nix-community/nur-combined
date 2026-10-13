{
  lib,
  stdenv,
  buildNpmPackage,
  fetchurl,
  nodejs_24,
  autoPatchelfHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "rea-agents";
  version = "6.4.0";

  # The npm tarball ships the compiled dist/ tree, so no TypeScript toolchain
  # is needed. It omits the lockfile, which is taken from the matching tag.
  src = fetchurl {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${finalAttrs.version}.tgz";
    sha256 = "sha256-WesWBLjbdfUi1Kl1w2zmtKKtRl5DutFl+aj3KDkdubg=";
  };

  packageLock = fetchurl {
    url = "https://raw.githubusercontent.com/morluto/rea/rea-agents-${finalAttrs.version}/package-lock.json";
    sha256 = "sha256-tlXiEYl71yAy72kmG+hxDlA3se3neBBsj+9zAwetAFk=";
  };

  postPatch = ''
    cp ${finalAttrs.packageLock} package-lock.json
  '';

  npmDepsHash = "sha256-XuiMtaM/MPDkhjiHCr9dGC7WlsRBmsWepuNHRxAs3Nw=";

  nodejs = nodejs_24;

  # dist/ is prebuilt; the upstream build and prepack scripts need the
  # source checkout and dev tooling, which the published package lacks.
  dontNpmBuild = true;
  npmPackFlags = [ "--ignore-scripts" ];

  # @lydell/node-pty ships prebuilt pty.node addons.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  meta = with lib; {
    description = "Reverse-engineering tools and MCP server for coding agents";
    homepage = "https://rea.tools/";
    changelog = "https://github.com/morluto/rea/releases/tag/rea-agents-${finalAttrs.version}";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "rea";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
