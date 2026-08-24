{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
  ladspa-header,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "plugalyzer";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "CrushedPixel";
    repo = "Plugalyzer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UmeSQi77OQnSjCBD1BgW8Iu/c+IoxipGlVfw5X7nWQo=";
    fetchSubmodules = true;
    # https://github.com/NixOS/nixpkgs/issues/195117
    preFetch = ''
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
    '';
  };

  nativeBuildInputs = [ juceCmakeHook ];

  buildInputs = [ ladspa-header ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp Plugalyzer_artefacts/Release/Plugalyzer $out/bin

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line VST3, AU and LADSPA plugin host for easier debugging of audio plugins";
    homepage = "https://github.com/CrushedPixel/Plugalyzer";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Plugalyzer";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
