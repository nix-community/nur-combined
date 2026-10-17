{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nix-update-script,
  callPackage,
  nodejs_24,
  pnpm_12,
  pnpmConfigHook,
  autoPatchelfHook,
  llvmPackages,
  musl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cf";
  version = "1.0.0-beta.18";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf";
    tag = "cf@${finalAttrs.version}";
    hash = "sha256-3AjBiAO5mlEMMyzTrq5n3gnhyI7WL8vSTIHIo0bt9ig=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_12;
    fetcherVersion = 4;
    hash = "sha256-UyBnE3ANRFGym/AT+MdgK9lsUwJPouMC6PwUAOpHakk=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs_24
    pnpm_12
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    llvmPackages.libcxx
    llvmPackages.libunwind
    musl
  ];

  env.NODE_OPTIONS = "--max-old-space-size=4096";

  preBuild = lib.optionalString stdenv.hostPlatform.isLinux ''
    autoPatchelf node_modules
  '';

  buildPhase = ''
    runHook preBuild
    pnpm --filter cf exec vp pack
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    pnpm --config.inject-workspace-packages=true --filter cf --prod deploy \
      --offline --ignore-scripts $out/lib/cf
    makeWrapper ${lib.getExe nodejs_24} $out/bin/cf \
      --add-flags "$out/lib/cf/bin/cf"
    ln -s cf $out/bin/cloudflare
    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = "cf";
      extraArgs = [
        "-f"
        "."
        "--use-github-releases"
        "--version=unstable"
        "--version-regex=^cf@(.*)$"
      ];
    };
    tests.packaging = callPackage ../../tests/pkgs/cf.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Command-line interface for the Cloudflare API";
    homepage = "https://github.com/cloudflare/cf";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "cf";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
