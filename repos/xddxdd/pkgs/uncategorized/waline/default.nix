{
  fetchurl,
  lib,
  buildNpmPackage,
  nodejs,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "waline";
  version = "1.41.6";
  src = fetchurl {
    url = "https://registry.npmjs.org/@waline/vercel/-/vercel-${finalAttrs.version}.tgz";
    hash = "sha256-v0xujYmA40jf3dTswOOGsyL+OZJna3E4VUt5V5goBQw=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-Z8M2gHzpQHCCmYQEwSIh/RBVsZnH+FIHJ6fJNIm1KJk=";

  patches = [ ./runtime-path.patch ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/waline \
      --add-flags "$out/lib/node_modules/@waline/vercel/vanilla.js"
  '';

  meta = {
    description = "Server for the Waline comment system";
    homepage = "https://github.com/walinejs/waline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "waline";
    platforms = lib.platforms.linux;
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };
})
