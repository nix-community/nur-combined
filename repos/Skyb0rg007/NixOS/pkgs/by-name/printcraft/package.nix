{
  lib,
  stdenv,
  fetchFromGitHub,
  makeRustPlatform,
  rustPackages,
  rustPlatform,
  llvmPackages_22,
  mesa,
  vulkan-loader,
  nix-update-script,
  copyDesktopItems,
  makeDesktopItem,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  wayland,
}:
let
  # rustc 1.98's stdarch declares the AVX-VNNI intrinsics with LLVM 22
  # signatures, but nixpkgs links rustc against LLVM 21, so calling e.g.
  # `_mm512_dpbusd_epi32` (rten-gemm) fails with "intrinsic signature mismatch".
  llvmShared = llvmPackages_22.libllvm.override { enableSharedLibraries = true; };
  rustPlatform' =
    if stdenv.hostPlatform.isx86_64 then
      makeRustPlatform {
        inherit (rustPackages) cargo;
        rustc = rustPackages.rustc.override {
          rustc-unwrapped = rustPackages.rustc-unwrapped.override {
            inherit llvmShared;
            llvmSharedForBuild = llvmShared;
            llvmSharedForHost = llvmShared;
            llvmSharedForTarget = llvmShared;
            llvmPackages = llvmPackages_22;
          };
        };
      }
    else
      rustPlatform;
in
rustPlatform'.buildRustPackage (finalAttrs: {
  pname = "printcraft";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "storytold";
    repo = "printcraft";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XRjNp87xei9tfU0KNLnf6Us90yGxQs3nfN0b/qGDld4=";
  };

  cargoHash = "sha256-Azzns+xa2bx6jn9XkL8RxvJ6PEXihWKtdASVtz1QblI=";

  nativeBuildInputs = [ copyDesktopItems ];

  cargoBuildFlags = [
    "-p"
    "printcraft"
    "-p"
    "printcraft-cli"
  ];

  postInstall = ''
    mkdir -p $out/share/icons $out/share/mime/packages
    cp -R assets/app-icon/hicolor $out/share/icons/
    cp packaging/linux/ai.storyteller.printcraft.mime.xml $out/share/mime/packages/ai.storyteller.printcraft.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ai.storyteller.printcraft";
      desktopName = "PrintCraft";
      genericName = "PDF Editor";
      comment = "Read, organize, combine, split and secure PDFs";
      exec = "printcraft %F";
      tryExec = "printcraft";
      icon = "ai.storyteller.printcraft";
      terminal = false;
      startupNotify = true;
      startupWMClass = "printcraft";
      categories = [
        "Office"
        "Viewer"
        "Graphics"
      ];
      keywords = [
        "pdf"
        "viewer"
        "editor"
        "annotate"
        "sign"
        "forms"
        "merge"
        "split"
      ];
      mimeTypes = [ "application/pdf" ];
    })
  ];

  # winit and wgpu dlopen() their windowing and graphics backends.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath ${
      lib.makeLibraryPath [
        libGL
        libx11
        libxcursor
        libxi
        libxkbcommon
        libxrandr
        vulkan-loader
        wayland
      ]
    } $out/bin/printcraft
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  # The egui_kittest UI tests render through wgpu; give them Mesa's lavapipe.
  preCheck = lib.optionalString stdenv.hostPlatform.isLinux ''
    export LD_LIBRARY_PATH=${lib.makeLibraryPath [ vulkan-loader ]}
    export VK_ICD_FILENAMES=${mesa}/share/vulkan/icd.d/lvp_icd.${stdenv.hostPlatform.uname.processor}.json
  '';

  meta = {
    homepage = "https://getartcraft.com/apps/printcraft";
    description = "Open-source, clean-room reimplementation of Adobe Acrobat";
    license =
      with lib.licenses;
      OR [
        mit
        asl20
      ];
    platforms = lib.platforms.all;
    # Rebuilds rustc against LLVM 22, too slow for CI.
    hydraPlatforms = [ ];
  };
})
