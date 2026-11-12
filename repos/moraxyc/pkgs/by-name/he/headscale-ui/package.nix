{
  lib,
  stdenv,
  buildNpmPackage,
  importNpmLock,
  installDistHook,
  nodejs,

  sources,
  source ? sources.headscale-ui,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname src;
  version = lib.replaceString "-" "." source.date;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  preBuild = ''
    substituteInPlace ./src/routes/settings.html/+page.svelte \
      --replace-fail "insert-version" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [ nodejs ];

  npmInstallHook = installDistHook;
  installDistDir = "build";

  meta = {
    description = "Web frontend for the headscale Tailscale-compatible coordination server";
    homepage = "https://github.com/gurucomputing/headscale-ui";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ moraxyc ];
    broken = stdenv.hostPlatform.isLoongArch64;
  };
})
