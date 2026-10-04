{
  alvr,
  android-tools,
  fetchFromGitHub,
  ffmpeg_8,
  glibc,
  lib,
  maintainer,
  makeBinaryWrapper,
  nix-update,
  replaceVars,
  rustPlatform,
  vulkan-headers,
  writeShellApplication,
  x264,
}:

let
  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-CEqJkHcrhicfT0czpgC+dM5gxw/QxKMB2PWHJoGNXuo=";
    owner = "alvr-org";
    repo = "ALVR";
    rev = "ee6d3b1669e4d8526fa46dbf29567e1a6d604459";
  };

  # ALVR master uses FFmpeg 8.1 and patches its encoder; Nixpkgs ALVR uses FFmpeg 6.0.
  ffmpeg-alvr =
    (ffmpeg_8.override {
      hash = "sha256-FdKhhCveEo5UodEoyUh3aBHABv3OT2VXmwBXE1ce3p0=";
      version = "8.1";
      withDocumentation = false;
      withHardcodedTables = false;
      withHtmlDoc = false;
      withManPages = false;
      withPodDoc = false;
      withTxtDoc = false;
    }).overrideAttrs
      (oldAttrs: {
        doCheck = false;
        patches =
          oldAttrs.patches
          ++ map (name: src + "/alvr/xtask/patches/${name}") [
            "0001-lavu-hwcontext_vulkan-Fix-importing-RGBx-frames-to-C.patch"
            "0002-vaapi_encode-Force-enable-global-header.patch"
            "0003-vaapi_encode_h265-Set-vui_parameters_present_flag.patch"
            "0004-vaapi_encode-Allow-to-dynamically-change-bitrate-and.patch"
            "0005-vaapi_encode-Add-filler_data-option.patch"
            "0006-Add-AV_VAAPI_DRIVER_QUIRK_HEVC_ENCODER_ALIGN_64_16-f.patch"
          ];
      });
in
(alvr.override { inherit ffmpeg-alvr; }).overrideAttrs (oldAttrs: {
  # buildRustPackage captures the release cargoHash before overrideAttrs runs.
  cargoDeps = rustPlatform.fetchCargoVendor {
    hash = "sha256-Wj8FVh8X7biYf/Fnjz/9t7jRfG85j9W21Pae5RnXZVA=";
    inherit src;
  };

  meta = oldAttrs.meta // {
    changelog = "https://github.com/alvr-org/ALVR/commits/master/";
    maintainers = oldAttrs.meta.maintainers ++ [ maintainer ];
  };

  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
    # The hook clears linker flags; pass static linking and libc directly to its compiler.
    (makeBinaryWrapper.overrideAttrs (attrs: {
      cc = "${attrs.cc} -static -L${glibc.static}/lib";
    }))
  ];

  passthru = oldAttrs.passthru // {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-alvr-git";
      runtimeInputs = [ nix-update ];
      text = ''
        # ALVR release tags do not track master; update this override and its Cargo hash.
        nix-update --flake --version branch=master \
          --override-filename pkgs/alvr-git/default.nix alvr-git
      '';
    });
  };

  postInstall = ''
    install -Dm755 ${src}/alvr/xtask/resources/alvr.desktop $out/share/applications/alvr.desktop
    install -Dm644 ${src}/resources/ALVR-Icon.svg $out/share/icons/hicolor/scalable/apps/alvr.svg

    # Direct mode no longer generates the Vulkan layer's share directory.
    mkdir -p $out/{libexec,lib/alvr,share}
    cp -r ./build/alvr_streamer_linux/lib64/. $out/lib
    cp -r ./build/alvr_streamer_linux/libexec/. $out/libexec
    ln -s $out/lib $out/lib64

    # ALVR looks for adb beside its binaries when installing the Quest client.
    mkdir -p $out/bin/platform-tools
    # Static linking lets the wrapper clear Steam's incompatible library path before loading adb.
    makeBinaryWrapper ${android-tools}/bin/adb "$out/bin/platform-tools/adb" \
      --unset LD_LIBRARY_PATH
  '';

  # The release patch targets an older build script and its FFmpeg 6.0 dependency.
  patches = [
    (replaceVars ./fix-finding-libs.patch {
      ffmpeg = lib.getDev ffmpeg-alvr;
      vulkanHeaders = lib.getDev vulkan-headers;
      x264 = lib.getDev x264;
    })
  ];

  pname = "alvr-git";
  inherit src;
  version = "20.14.1-unstable-2026-10-04";
})
