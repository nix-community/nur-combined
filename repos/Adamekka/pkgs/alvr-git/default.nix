{
  alvr,
  fetchFromGitHub,
  ffmpeg_8,
  lib,
  maintainer,
  replaceVars,
  rustPlatform,
  unstableGitUpdater,
  vulkan-headers,
  x264,
}:

let
  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-ZoBzuxLVXmn5/YRHEQWRQnPCXhuRv4LZDxe4FNuC/Ho=";
    owner = "alvr-org";
    repo = "ALVR";
    rev = "99d8948d90ffe53a05f396d9a588a33fb7583861";
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
    hash = "sha256-5yzFedwUtWrm180GPYAXr69G9S0o7wKUnYBw1g+Zre0=";
    inherit src;
  };

  meta = oldAttrs.meta // {
    changelog = "https://github.com/alvr-org/ALVR/commits/master/";
    maintainers = oldAttrs.meta.maintainers ++ [ maintainer ];
  };

  passthru = oldAttrs.passthru // {
    updateScript = unstableGitUpdater {
      branch = "master";
      tagPrefix = "v";
      url = "https://github.com/alvr-org/ALVR.git";
    };
  };

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
  version = "20.14.1-unstable-2026-09-24";
})
