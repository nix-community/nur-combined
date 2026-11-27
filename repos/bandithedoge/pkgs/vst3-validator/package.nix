{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  gtk3,
  gtkmm3,
  libx11,
  ninja,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vst3-validator";
  version = "3.8.1_build_84";
  src = fetchFromGitHub {
    owner = "steinbergmedia";
    repo = "vst3sdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TZFWI+liUtdtU5791zuK0wB9eGpIKSGdDpI74fo8beM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  cmakeFlags = [
    "-DSMTG_ENABLE_VST3_PLUGIN_EXAMPLES=OFF"
    "-DSMTG_ENABLE_VSTGUI_SUPPORT=OFF"
    "-DSMTG_ENABLE_HOSTING_EXAMPLES=OFF"
  ];

  buildInputs = [
    libx11
    gtk3
    gtkmm3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/Release/{editorhost,moduleinfotool,validator} $out/bin

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Small command line host application which can be used to check your plug-in for VST 3 conformity";
    homepage = "https://steinbergmedia.github.io/vst3_dev_portal/pages/What+is+the+VST+3+SDK/Validator.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bandithedoge ];
    mainProgram = "validator";
    platforms = lib.platforms.unix;
  };
})
