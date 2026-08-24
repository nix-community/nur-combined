{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hise";
  version = "4.1.0";
  src = fetchFromGitHub {
    owner = "christophhart";
    repo = "HISE";
    rev = finalAttrs.version;
    hash = "sha256-SsreYLRuxv4eXieH0u/TOSvjBAKh820lQeacodKLu8Q=";
  };

  nativeBuildInputs = [
    projucer
    unzip
  ];

  jucerFile = "HISE Standalone.jucer";
  dontUseProjucerInstall = true;

  postPatch = ''
    unzip tools/SDK/sdk.zip -d tools/SDK
  '';

  preConfigure = ''
    cd projects/standalone
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp "build/HISE Standalone" $out/bin/HISE

    runHook postInstall
  '';

  dontStrip = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "The open source toolkit for building virtual instruments and audio effects";
    homepage = "https://hise.dev";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "HISE";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
