{
  sources,
  lib,
  stdenvNoCC,
  buildGoModule,
  bun,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  writeShellScript,
  gnugrep,
  binutils,
}:
let
  frontendDist = stdenvNoCC.mkDerivation {
    pname = "${sources.new-api.pname}-frontend-dist";
    inherit (sources.new-api) version src;
    sourceRoot = "source/web";
    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-1M5V1vnFX4BoXr+h0Or+nPQePdnI4meXPrgwfrr35Ss=";
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      bun install --frozen-lockfile
      export VITE_REACT_APP_VERSION=${sources.new-api.version}
      (cd default && DISABLE_ESLINT_PLUGIN='true' bun node_modules/@rsbuild/core/bin/rsbuild.js build)
      (cd classic && bun node_modules/@rsbuild/core/bin/rsbuild.js build)
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/default $out/classic
      cp -a default/dist/. $out/default/dist/
      cp -a classic/dist/. $out/classic/dist/
      runHook postInstall
    '';
  };
in
buildGoModule (finalAttrs: {
  inherit (sources.new-api) pname version src;
  vendorHash = "sha256-vV5ALqG/e4GxXM5gDBbpH6e5GMZhtESXugjfTu4oUPE=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/QuantumNous/new-api/common.Version=v${finalAttrs.version}"
  ];

  preBuild = ''
    mkdir -p web/default/dist web/classic/dist
    cp -r ${frontendDist}/default/dist/* web/default/dist/
    cp -r ${frontendDist}/classic/dist/* web/classic/dist/
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  doInstallCheck = true;
  versionCheckProgram = writeShellScript "new-api-version-check" ''
    ${binutils}/bin/strings $1 | ${gnugrep}/bin/grep -F "v${finalAttrs.version}"
  '';
  versionCheckProgramArg = "${placeholder "out"}/bin/new-api";

  meta = {
    changelog = "https://github.com/QuantumNous/new-api/releases/tag/v${finalAttrs.version}";
    description = "AI model gateway for aggregation and distribution, supports converting LLMs into OpenAI-compatible, Claude-compatible, or Gemini-compatible formats";
    homepage = "https://github.com/QuantumNous/new-api";
    license = lib.licenses.agpl3Only;
    mainProgram = "new-api";
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
