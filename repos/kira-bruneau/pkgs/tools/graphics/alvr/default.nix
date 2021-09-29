{ rustPlatform
, fetchFromGitHub
, pkg-config
, alsaLib
, ffmpeg
, openssl
, vulkan-headers
, libclang

, enableDebugging
, fetchurl

, binutils-unwrapped
, glib
, ffmpeg-full
, cairo
, pango
, atk
, gdk-pixbuf
, gtk3
, clang
, vulkan-tools-lunarg
, vulkan-loader
, vulkan-validation-layers
, xorg
, libunwind
, python3
, libxkbcommon

}:

rustPlatform.buildRustPackage rec {
  pname = "ALVR";
  version = "16.0.0";

  src = fetchFromGitHub {
    owner = "alvr-org";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-9q7NPWZZuwtDfZzJJFyJQLwfWV1k6e+4tQhnbBzr87E=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsaLib
    # ffmpeg.dev
    openssl
    vulkan-headers

    binutils-unwrapped
    # alsaLib
    # openssl
    glib
    (ffmpeg-full.override { nonfreeLicensing = true; })
    cairo
    pango
    atk
    gdk-pixbuf
    gtk3
    clang
    (vulkan-tools-lunarg.overrideAttrs (oldAttrs: rec {
      patches = [
        (fetchurl {
          url =
            "https://gist.githubusercontent.com/ckiee/038809f55f658595107b2da41acff298/raw/6d8d0a91bfd335a25e88cc76eec5c22bf1ece611/vulkantools-log.patch";
          sha256 = "14gji272r53pykaadkh6rswlzwhh9iqsy1y4q0gdp8ai4ycqd129";
        })
      ];
    }))
    # vulkan-headers
    vulkan-loader
    vulkan-validation-layers
    xorg.libX11
    xorg.libXrandr
    libunwind
    python3 # for the xcb crate
    libxkbcommon
  ];

  CXX="clang++";

  LIBCLANG_PATH="${libclang.lib}/lib";

  cargoHash = "sha256-To2Mt8SAlmUXf+CggDZ9jDi1nDIUGcnzDlb4M4F9Gk8=";
}
