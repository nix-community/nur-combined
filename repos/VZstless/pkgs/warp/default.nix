{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  cmake,
  protobuf,
  perl,
  python3,
  fontconfig,
  libxkbcommon,
  vulkan-loader,
  wayland,
  libGL,
  alsa-lib,
  curl,
  zlib,
  xz,
  openssl,
  dbus,
  libglvnd,
  nss,
  gtk3,
  libX11,
  libXScrnSaver,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  seatd,
  stdenv,
}:

let
  protoApisSrc = fetchFromGitHub {
    owner = "warpdotdev";
    repo = "warp-proto-apis";
    rev = "63b333d02da4d95a716796331cb5c3049d369a7e";
    hash = "sha256-/xJtVVF/hE0ovdstQ9qWZpYtQvNxRQsvKQacnYH/5wA=";
  };
  workflowsSrc = fetchFromGitHub {
    owner = "warpdotdev";
    repo = "workflows";
    rev = "793a98ddda6ef19682aed66364faebd2829f0e01";
    hash = "sha256-ICgkxlUUIfyhr0agZEk3KtGHX0uNRlRCKtz0iF2jd7o=";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "warp";
  version = "0.2026.05.13.09.14.stable_00";

  src = fetchFromGitHub {
    owner = "warpdotdev";
    repo = "warp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9dWdQ4S6BL8jKbmxiuTQ/+w3Nb3iVEKzVWYtrCMa/AY=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "command-corrections-0.0.0" = "sha256-dV7UzRxIF5K9TH0lOTONMVhTcEO0VmquWf4AB/k4hA0=";
      "core-foundation-0.10.1" = "sha256-LkBjnI/aE1H5H4+TF1O458YDWhareJlnZlEx3OcD07I=";
      "core-foundation-sys-0.8.7" = "sha256-LkBjnI/aE1H5H4+TF1O458YDWhareJlnZlEx3OcD07I=";
      "core-graphics-0.25.0" = "sha256-LkBjnI/aE1H5H4+TF1O458YDWhareJlnZlEx3OcD07I=";
      "core-graphics-types-0.2.0" = "sha256-LkBjnI/aE1H5H4+TF1O458YDWhareJlnZlEx3OcD07I=";
      "core-text-21.1.0" = "sha256-LkBjnI/aE1H5H4+TF1O458YDWhareJlnZlEx3OcD07I=";
      "cosmic-text-0.12.0" = "sha256-xuUTf6qdbGryKLLmjl4kP0X8u7SMk9WWFq32GibxC2U=";
      "dagre_rust-0.0.5" = "sha256-+f6BVuvhu1nhmu8Uu2exwGifrMmoosov/7AE41IEIj8=";
      "difflib-0.4.0" = "sha256-nN54WUgZagDvmdo2hYwaeGsWOXuIwOLNrlnvPxuKhKU=";
      "dpi-0.1.1" = "sha256-6fyP7+qp1AklfUFWDuJqvChHaU/nj/4Xyc+SGE/ligs=";
      "dwrote-0.11.5" = "sha256-2XeWdLMuVmaBfG9AcNYyVJX1QUXxBvjc9mlGl8szxl0=";
      "email_address-0.2.3" = "sha256-OZUExG8rbBgPlGMGlWR72dSsnyYxNOsIgHQ1tAoX5f4=";
      "file-id-0.2.2" = "sha256-qpkWIt2be1FXa0Ua9IkKeFNnoW70m3bhJ9wXRNzqi6I=";
      "font-kit-0.12.0" = "sha256-exECbZ7eQv+WdpXu4gEfSeryChqTlyQrHSQEN/0yKrY=";
      "mermaid_to_svg-0.1.0" = "sha256-+f6BVuvhu1nhmu8Uu2exwGifrMmoosov/7AE41IEIj8=";
      "notify-8.0.0" = "sha256-qpkWIt2be1FXa0Ua9IkKeFNnoW70m3bhJ9wXRNzqi6I=";
      "notify-debouncer-full-0.5.0" = "sha256-qpkWIt2be1FXa0Ua9IkKeFNnoW70m3bhJ9wXRNzqi6I=";
      "notify-types-2.0.0" = "sha256-qpkWIt2be1FXa0Ua9IkKeFNnoW70m3bhJ9wXRNzqi6I=";
      "objc-0.2.7" = "sha256-+Fqo8+HX5Dz5VZMRZinpqzPqB71FX7UHxEbxArdfNVI=";
      "pathfinder_simd-0.5.4" = "sha256-EYaGJLCgEkCtTaIPgIAhRo8m9p6ncUYYeYFgl6oQQ1Q=";
      "rmcp-0.10.0" = "sha256-sAa4RZsnmnYKKnoCHOxwOGDJuBJJeXrEqbXE6MsxTwg=";
      "rmcp-macros-0.10.0" = "sha256-sAa4RZsnmnYKKnoCHOxwOGDJuBJJeXrEqbXE6MsxTwg=";
      "session-sharing-protocol-0.0.0" = "sha256-9gQAoUaJ8c7Fi5c2khOdGq1eZWXcCXlU5I4jcotH6YM=";
      "tikv-jemallocator-0.6.1" = "sha256-SaTS9bT3OCD9r1SzFHvu4CEYYL7sGxpU2DbQi26zRbQ=";
      "tikv-jemalloc-sys-0.6.1+5.3.0-1-g0d7a26e9b6faa4ea33601ee605b5d86b68ff7790" = "sha256-SaTS9bT3OCD9r1SzFHvu4CEYYL7sGxpU2DbQi26zRbQ=";
      "tink-core-0.3.0" = "sha256-AXguXcXhAPrYS9eUfO+6r0FmlztpENFE1tsC+PRWDPA=";
      "tink-hybrid-0.3.0" = "sha256-AXguXcXhAPrYS9eUfO+6r0FmlztpENFE1tsC+PRWDPA=";
      "tink-proto-0.3.0" = "sha256-AXguXcXhAPrYS9eUfO+6r0FmlztpENFE1tsC+PRWDPA=";
      "uneval-0.2.3" = "sha256-UPMOQaCQAkgrrbiUXudcps8zS/2j0ex0pi2aWcaNt6s=";
      "utf8parse-0.2.1" = "sha256-kaM0tEdpzGkpDOXvywXd8cy5M+sgWZBXHWFYSCLlJ3k=";
      "vte-0.13.0" = "sha256-kaM0tEdpzGkpDOXvywXd8cy5M+sgWZBXHWFYSCLlJ3k=";
      "vte_generate_state_changes-0.1.1" = "sha256-kaM0tEdpzGkpDOXvywXd8cy5M+sgWZBXHWFYSCLlJ3k=";
      "warp-command-signatures-0.0.0" = "sha256-mpOc8xxdqLh/Zjp6/eIvYuuQn7yzLNTIXV8lI1mU48c=";
      "warp-completion-metadata-0.0.0" = "sha256-mpOc8xxdqLh/Zjp6/eIvYuuQn7yzLNTIXV8lI1mU48c=";
      "warp_multi_agent_api-0.0.0" = "sha256-/xJtVVF/hE0ovdstQ9qWZpYtQvNxRQsvKQacnYH/5wA=";
      "warp-workflows-0.1.0" = "sha256-ICgkxlUUIfyhr0agZEk3KtGHX0uNRlRCKtz0iF2jd7o=";
      "warp-workflows-types-0.1.0" = "sha256-ICgkxlUUIfyhr0agZEk3KtGHX0uNRlRCKtz0iF2jd7o=";
      "winit-0.30.1" = "sha256-6fyP7+qp1AklfUFWDuJqvChHaU/nj/4Xyc+SGE/ligs=";
      "yaml-rust-0.4.5" = "sha256-C7CXEw4rTnkZlXWCAyMOJ4BIelapB1AQ3HCzsnr0rcI=";
    };
  };

  postUnpack = ''
    cp ${./Cargo.lock} $sourceRoot/Cargo.lock
  '';

  preConfigure = ''
    vendorDir="/build/cargo-vendor-dir"

    # Fix warp_multi_agent_api: nix flattens the workspace git repo so the
    # build.rs at root cant find proto files at ../../ relative path
    agentApiDir="$vendorDir/warp_multi_agent_api-0.0.0"
    if [ -d "$agentApiDir" ]; then
      protoSrc="${protoApisSrc}/apis/multi_agent/v1"
      protoDst="$agentApiDir/apis/multi_agent/v1"
      mkdir -p "$protoDst"
      cp "$protoSrc"/*.proto "$protoDst/"
      buildRs="$agentApiDir/build.rs"
      if [ -f "$buildRs" ]; then
        sed -i 's|manifest_dir.parent().unwrap().parent().unwrap()|manifest_dir.join("apis/multi_agent/v1")|g' "$buildRs"
      fi
    fi

    # Fix warp-workflows: same issue - build.rs references ../specs
    # which doesn't exist in the flattened vendor dir
    workflowsDir="$vendorDir/warp-workflows-0.1.0"
    if [ -d "$workflowsDir" ] && [ -d "${workflowsSrc}" ]; then
      specSrc="${workflowsSrc}/specs"
      specDst="$workflowsDir/specs"
      mkdir -p "$(dirname "$specDst")"
      cp -r "$specSrc" "$specDst/"
      buildRs="$workflowsDir/build.rs"
      if [ -f "$buildRs" ]; then
        sed -i 's|"../specs"|"specs"|g' "$buildRs"
      fi
    fi
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    cmake
    protobuf
    perl
    python3
  ];

  buildInputs = [
    alsa-lib
    curl
    dbus
    fontconfig
    gtk3
    libGL
    libglvnd
    seatd
    libxkbcommon
    nss
    openssl
    vulkan-loader
    wayland
    libX11
    libxcursor
    libxi
    libxrandr
    libxcb
    xz
    zlib
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    libXScrnSaver
  ];

  doCheck = false;

  cargoBuildFlags = [
    "-p"
    "warp"
    "--bin"
    "warp-oss"
  ];

  postInstall = ''
    wrapProgram $out/bin/warp-oss \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        alsa-lib
        curl
        dbus
        fontconfig
        gtk3
        libGL
        libglvnd
        seatd
        libxkbcommon
        nss
        openssl
        vulkan-loader
        wayland
        libX11
        libxcursor
        libxi
        libxrandr
        libxcb
        zlib
      ]}"
  '';

  meta = {
    description = "An agentic terminal built for coding with AI agents";
    homepage = "https://www.warp.dev";
    license = lib.licenses.agpl3Only;
    # VZstless: I don't want to adopt this fxxking thing, bring it orphaned!
    mainProgram = "warp-oss";
    platforms = lib.platforms.linux;
  };
})
