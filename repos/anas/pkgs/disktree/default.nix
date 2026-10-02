{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, addDriverRunpath
, git
, fontconfig
, libX11
, libxcb
, libxkbcommon
, vulkan-loader
, libGL
}:

let
  pname = "disktree";
  version = "0.10.1";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "tobi";
    repo = "disktree";
    rev = "v${version}";
    hash = "sha256-HoJjSLQeLEK20SpEd40DakAwV6WTdtcWM779YCjI3Jk=";
  };

  cargoHash = "sha256-+IG75eHRo1+4Sg5dq+b77UWYLKQlqPH30WtAnND/Cbk=";

  nativeBuildInputs = [
    pkg-config
    addDriverRunpath
  ];

  buildInputs = [
    git
    fontconfig
    libX11
    libxcb
    libxkbcommon
  ];

  # wgpu dlopens the GL and Vulkan loaders (libEGL.so.1, libvulkan.so.1)
  # instead of linking them, so they end up neither in the closure nor on the
  # RPATH: wgpu then fails to create a hal instance at all and opening the
  # window panics with "Failed to create surface for any enabled backend".
  # The loaders come from the closure, the drivers from the session.
  postFixup = ''
    patchelf --set-rpath \
      "${lib.makeLibraryPath [ libGL vulkan-loader ]}:$(patchelf --print-rpath "$out/bin/disktree")" \
      "$out/bin/disktree"
    addDriverRunpath "$out/bin/disktree"
  '';

  # There is no tests
  doCheck = false;

  meta = {
    description = "A treemap for finding and removing what fills your disk, for Omarchy. Rust + GPUI.";
    homepage = "https://github.com/tobi/disktree";
    license = lib.licenses.mit;
    mainProgram = "disktree";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
