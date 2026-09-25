{
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  stdenvNoCC,
  clang,
  gotools,
  buildGoModule,
  fetchFromGitHub,
  lib,
  _experimental-update-script-combinators,
  nixosTests,
  nix-update-script,
}:
let
  pnpm = pnpm_10;
in
buildGoModule (finalAttrs: {
  pname = "daed";
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "daed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F8Q97sGA4sMgupb31+nFT55sdx/Jr1mgwOjb45o9hlc=";
    fetchSubmodules = true;
  };

  sourceRoot = "${finalAttrs.src.name}/wing";

  web = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) pname version src;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        ;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-CL21Q9y5C2TGbu8yppXTt7fZQfyMlePQXyMh2cVg5TE=";
    };

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    strictDeps = true;
    __structuredAttrs = true;

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R apps/web/dist/* $out

      runHook postInstall
    '';
  };

  vendorHash = "sha256-+YQ/Ia54N/QKwd9p4AePg3CMjQvc4mFE1EcA/JPc8Po=";
  proxyVendor = true;

  nativeBuildInputs = [
    clang
    gotools
  ];

  hardeningDisable = [ "zerocallusedregs" ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace-fail /bin/bash /bin/sh

    substituteInPlace graphql/service/config/global/global.go \
      --replace-fail "go run -mod=mod golang.org/x/tools/cmd/goimports -w generated_resolver.go generated_input.go" \
                     "goimports -w generated_resolver.go generated_input.go"
  '';

  buildPhase = ''
    runHook preBuild

    # ${finalAttrs.web} does not have write permission
    mkdir dist
    cp -r ${finalAttrs.web}/* dist
    chmod -R 755 dist

    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
      NOSTRIP=y \
      WEB_DIST=dist \
      AppName=daed \
      VERSION=${finalAttrs.version} \
      OUTPUT=$out/bin/daed \
      bundle

    runHook postBuild
  '';

  postInstall = ''
    install -Dm444 $src/install/daed.service -t $out/lib/systemd/system
    substituteInPlace $out/lib/systemd/system/daed.service \
      --replace-fail /usr/bin $out/bin
  '';

  passthru = {
    inherit (finalAttrs) web;
    tests = { inherit (nixosTests) daed; };
    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        attrPath = "daed.web";
        extraArgs = [ "--use-github-releases" ];
      })
      (nix-update-script {
        extraArgs = [ "--version=skip" ];
      })
    ];
  };

  meta = {
    description = "Modern dashboard with dae";
    homepage = "https://github.com/daeuniverse/daed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      oluceps
      ccicnce113424
    ];
    platforms = lib.platforms.linux;
    mainProgram = "daed";
  };
})
