{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  darwin,
  stdenv,
  vulkan-loader,
  wayland,
  libxkbcommon,
  xorg,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nohrs";
  version = builtins.substring 0 7 finalAttrs.src.rev;

  src = fetchFromGitHub {
    owner = "noh-rs";
    repo = "nohrs";
    rev = "dcc658778358fabcf205cca189e98b8e3dd0c969";
    hash = "sha256-rwuUtItUhW/0kyqDxDyDyVFWorlOUAIdIrrSKpG4h0o=";
  };

  cargoHash = "sha256-LP48fTVvvq/bj/C5L7hwHI0LCUDK6PegxryWUDPl+ys=";

  nativeBuildInputs = [pkg-config] ++ lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks; [
        AppKit
        CoreFoundation
        CoreGraphics
        CoreServices
        CoreText
        Foundation
        IOKit
        Metal
        QuartzCore
        Security
        SystemConfiguration
      ]
    )
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      vulkan-loader
      wayland
      libxkbcommon
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libxcb
      openssl
    ];

  buildFeatures = ["gui"];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/nohrs \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      vulkan-loader
      wayland
      libxkbcommon
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
      xorg.libxcb
    ]}
  '';

  doCheck = false;

  meta = {
    description = "A fast, flexible, and extensible file explorer";
    homepage = "https://github.com/noh-rs/nohrs";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "nohrs";
    platforms = lib.platforms.unix;
  };
})
