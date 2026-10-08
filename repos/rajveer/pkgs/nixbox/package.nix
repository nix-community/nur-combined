{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  desktop-file-utils,
  fontconfig,
  freetype,
  vulkan-loader,
  wayland,
  libxkbcommon,
  libx11,
  libxcb,
  gh,
  git,
  jujutsu,
  nix,
  package ? "nixbox",
}:
let
  release = builtins.fromJSON (builtins.readFile ./source.json);
  gui = package == "nixbox-gui";
  guiLibraries = [
    vulkan-loader
    wayland
    libxkbcommon
    libx11
    libxcb
  ];
in
assert builtins.elem package [
  "nixbox"
  "nixbox-cli"
  "nixbox-gui"
];
rustPlatform.buildRustPackage {
  pname = package;
  inherit (release) version;
  src = fetchFromGitHub {
    owner = "SINGH-RAJVEER";
    repo = "nixbox";
    inherit (release) rev hash;
  };

  # Keeping the lock file local lets NUR evaluate without fetching the source.
  # Each registry dependency has its own checksum, so no aggregate cargoHash
  # needs to be recalculated when the release changes.
  cargoLock.lockFile = ./Cargo.lock;
  useNextest = true;
  nativeCheckInputs = [ git jujutsu ];
  cargoBuildFlags = [
    "--package"
    package
  ]
  ++ lib.optionals gui [
    "--features"
    "native"
  ];
  cargoTestFlags =
    if gui then
      [
        "--package"
        "nixbox-gui"
        "--features"
        "native"
      ]
    else if package == "nixbox" then
      [
        "--workspace"
        "--exclude"
        "nixbox-gui"
      ]
    else
      [
        "--package"
        "nixbox-cli"
        "--package"
        "nixbox-cmd"
      ];

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals gui [
    pkg-config
    desktop-file-utils
  ];
  buildInputs = lib.optionals gui (
    guiLibraries
    ++ [
      fontconfig
      freetype
    ]
  );

  postInstall = ''
    wrapProgram $out/bin/${package} \
      --prefix PATH : ${
        lib.makeBinPath [
          gh
          git
          jujutsu
          nix
        ]
      }${lib.optionalString gui " --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath guiLibraries}"}
    ${lib.optionalString gui ''
      install -Dm644 assets/nixbox-gui.svg "$out/share/icons/hicolor/scalable/apps/nixbox-gui.svg"
      install -Dm644 assets/nixbox-gui.desktop.in "$out/share/applications/nixbox-gui.desktop"
      substituteInPlace "$out/share/applications/nixbox-gui.desktop" \
        --replace-fail '@NIXBOX_GUI_EXEC@' "$out/bin/nixbox-gui"
      desktop-file-validate "$out/share/applications/nixbox-gui.desktop"
    ''}
  '';

  meta = {
    description =
      if gui then
        "Desktop package manager for NixOS and Home Manager"
      else if package == "nixbox-cli" then
        "Command-line package manager for NixOS and Home Manager"
      else
        "TUI package manager for NixOS and Home Manager";
    homepage = "https://github.com/SINGH-RAJVEER/nixbox";
    changelog = "https://github.com/SINGH-RAJVEER/nixbox/blob/${release.rev}/docs/RELEASE_NOTES.md";
    license = lib.licenses.asl20;
    mainProgram = package;
    platforms =
      if gui then
        [
          "x86_64-linux"
          "aarch64-linux"
        ]
      else
        [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
  };
}
