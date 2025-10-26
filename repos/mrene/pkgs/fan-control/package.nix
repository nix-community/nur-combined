{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libxkbcommon,
  vulkan-loader,
  stdenv,
  darwin,
  lm_sensors,
  xorg,
}:

let
  src = fetchFromGitHub {
    owner = "wiiznokes";
    repo = "fan-control";
    rev = "01c386794265dd3d8487013c0cdf7ad9111c5c9b";
    hash = "sha256-IxgY0J9xMu6Cc+b7zhoT7FM81TvGPFRT1zgHvnYGdBg=";
    fetchSubmodules = true;
  };

  # The package patches lm_sensors to provide more attributes
  sensors = lm_sensors.overrideAttrs (oldAttrs: {
    src = "${src}/hardware/libsensors";
  });
in

rustPlatform.buildRustPackage rec {
  pname = "fan-control";
  version = "2025.3.0";

  inherit src;

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "accesskit-0.16.0" = "sha256-yeBzocXxuvHmuPGMRebbsYSKSvN+8sUsmaSKlQDpW4w=";
      "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
      "clipboard_macos-0.1.0" = "sha256-tovB4fjPVVRY8LKn5albMzskFQ+1W5ul4jT5RXx9gKE=";
      "cosmic-config-0.1.0" = "sha256-saWOdcq+W721wPmkQc92aXLE+uKWRN1851/f0cYW/QY=";
      "cosmic-text-0.12.1" = "sha256-u2Tw+XhpIKeFg8Wgru/sjGw6GUZ2m50ZDmRBJ1IM66w=";
      "dpi-0.1.1" = "sha256-whi05/2vc3s5eAJTZ9TzVfGQ/EnfPr0S4PZZmbiYio0=";
      "iced_glyphon-0.6.0" = "sha256-u1vnsOjP8npQ57NNSikotuHxpi4Mp/rV9038vAgCsfQ=";
      "lm-sensors-0.2.0" = "sha256-A9h/yR7hOPj9vXVP+BfNfY6hU1Stbz5pAqueEZt/g38=";
      "smithay-clipboard-0.8.0" = "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
      "softbuffer-0.4.1" = "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
      "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.Metal
    darwin.apple_sdk.frameworks.QuartzCore
  ] ++ lib.optionals stdenv.isLinux [
    libxkbcommon
    xorg.libX11
    xorg.libXi
    sensors
    vulkan-loader
  ];
  
  env = {
    LMSENSORS_PATH = "${sensors}";
  };

  # Force link against libs loaded at runtime
  # If -lvulkan is not forced, it falls back to X11 mode which hits this bug:
  # https://github.com/wiiznokes/fan-control/issues/98 (Create softbuffer surface for window)
  RUSTFLAGS = map (a: "-C link-arg=${a}") [
    "-Wl,--push-state,--no-as-needed"
    "-lvulkan"
    "-lsensors"
    "-lxkbcommon"
    "-lX11"
    "-lXi"
    "-Wl,--pop-state"
  ];

  postPatch = ''
    substituteInPlace ./ui/src/localize.rs ./data/src/localize.rs \
      --replace '#[folder = "./../i18n/"]' '#[folder = "${src}/i18n/"]'
  '';

  # Fails inside sandbox:
  # Linux(LmSensors("failed to init libsensor", LMSensors { operation: "sensors_init()", number: 4, description: "Kernel interface error" }))
  doCheck = false;

  passthru = {
    inherit sensors;
  };

  meta = {
    description = "Control your fans with different behaviors";
    homepage = "https://github.com/wiiznokes/fan-control";
    changelog = "https://github.com/wiiznokes/fan-control/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "fan-control";
    platforms = lib.platforms.linux;
  };
}
