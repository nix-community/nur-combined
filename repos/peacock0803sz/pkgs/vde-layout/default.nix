{ lib, stdenv, fetchFromGitHub, nodejs, pnpm_10, makeWrapper }:
stdenv.mkDerivation (finalAttrs: {
  pname = "vde-layout";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "yuki-yano";
    repo = "vde-layout";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p/QO40lgySwi1iDQegv6Byg0lqzhCkx5YHnpuk8Qe2E=";
  };

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-S23FawDZBQ0mybe++ASUlWha0J5++4HfDGE+DN7imBc=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10.configHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/vde-layout $out/bin
    cp -r dist bin node_modules package.json $out/lib/vde-layout/
    makeWrapper ${lib.getExe nodejs} $out/bin/vde-layout \
      --add-flags $out/lib/vde-layout/bin/vde-layout
    runHook postInstall
  '';

  meta = {
    description = "Terminal multiplexer layout management tool for VDE";
    homepage = "https://github.com/yuki-yano/vde-layout";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "vde-layout";
  };
})
