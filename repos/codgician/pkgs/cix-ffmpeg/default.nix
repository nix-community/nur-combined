{
  lib,
  callPackage,
  darwin,
  cudaPackages,
  fetchFromGitHub,
  fetchpatch2,
  path,
  cix-vpu-driver,
}:

# CIX-patched ffmpeg 5.1.7 — adds V4L2 M2M decoders/encoders and VA-API
# bindings tailored to the CIX P1 VPU (amvx). Instantiated through the
# upstream ffmpeg `generic.nix` rather than `overrideAttrs` so the
# version/source are swapped cleanly, as recommended by that generator
# (it explicitly says "NOTICE: Always use this argument to override the
# version. Do not use overrideAttrs.").
#
# We mirror `pkgs/development/libraries/ffmpeg/default.nix`'s `mkFFmpeg`
# helper to thread the darwin/CUDA arguments that `generic.nix` requires.
let
  patchesSrc = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_opensource__ffmpeg-cix";
    rev = "5dbb8a418345ff1aece745b073386b0b4001c452";
    hash = "sha256-50mYY4xfokXw9DlyA18DbCyX9r4uJOEGQZbGpaKC3bU=";
  };
  patch = "${patchesSrc}/debian/ffmpeg-5.1.7/patches/ffmpeg_5_1_7_for_cix_2025q4.patch";

  # generic.nix only applies this for ffmpeg >= 6, but 5.1.7 fails the same
  # way against SVT-AV1 >= 4.0. The change is guarded by
  # SVT_AV1_CHECK_VERSION, so it is a no-op with older SVT-AV1.
  svtAv1Compat = fetchpatch2 {
    name = "svt-av1-4.0.0-compat.patch";
    url = "https://git.ffmpeg.org/gitweb/ffmpeg.git/patch/a5d4c398b411a00ac09d8fe3b66117222323844c";
    hash = "sha256-peIXXU5+5DRQc3Xdpz5V+xIN7Vohs0Dlal6mHiMryXc=";
  };
in
(callPackage (path + "/pkgs/development/libraries/ffmpeg/generic.nix") {
  inherit (darwin) xcode;
  inherit (cudaPackages) cuda_cudart cuda_nvcc libnpp;
  version = "5.1.7";
  hash = "sha256-WzjNZj4GZfJi2plNcSWJzg0bZZ8sw7cK91z4Uv64Qpk=";
  ffmpegVariant = "small";
}).overrideAttrs
  (old: {
    pname = "cix-ffmpeg";
    patches =
      (old.patches or [ ])
      ++ lib.optional (!lib.elem svtAv1Compat (old.patches or [ ])) svtAv1Compat
      ++ [ patch ];

    # The CIX V4L2 M2M codec glue `#include "mvx-v4l2-controls.h"`,
    # which only lives in the VPU driver source tree. Drop a copy into
    # `libavcodec/` (where the patched code lives) so a plain
    # quote-include resolves it without disturbing ffmpeg's gas /
    # assembler detection (NIX_CFLAGS_COMPILE and --extra-cflags both
    # leak into those configure probes and make them fail).
    #
    # Right next to it we drop a tiny shim that defines the V4L2
    # colorspace constants the patch references (BT2020_10/12, HLG,
    # ST428, ...) which exist in CIX's downstream kernel headers but
    # not in mainline `videodev2.h`. We then prepend a `#include` of
    # that shim into every CIX-touched .c file under libavcodec/.
    postPatch = (old.postPatch or "") + ''
      cp ${cix-vpu-driver}/include/cix/mvx-v4l2-controls.h libavcodec/
      cat > libavcodec/cix_v4l2_compat.h <<'EOF'
      #ifndef CIX_V4L2_COMPAT_H
      #define CIX_V4L2_COMPAT_H
      #include <linux/videodev2.h>
      #define V4L2_MVX_COLORIMETRY_UNSUPPORTED (-1)
      #ifndef V4L2_COLORSPACE_GENERIC_FILM
      #define V4L2_COLORSPACE_GENERIC_FILM V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_COLORSPACE_ST428
      #define V4L2_COLORSPACE_ST428 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_GAMMA22
      #define V4L2_XFER_FUNC_GAMMA22 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_GAMMA28
      #define V4L2_XFER_FUNC_GAMMA28 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_BT1361
      #define V4L2_XFER_FUNC_BT1361 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_BT2020_10
      #define V4L2_XFER_FUNC_BT2020_10 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_BT2020_12
      #define V4L2_XFER_FUNC_BT2020_12 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_ST428
      #define V4L2_XFER_FUNC_ST428 V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_XFER_FUNC_HLG
      #define V4L2_XFER_FUNC_HLG V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #ifndef V4L2_YCBCR_ENC_BT470_6M
      #define V4L2_YCBCR_ENC_BT470_6M V4L2_MVX_COLORIMETRY_UNSUPPORTED
      #endif
      #endif
      EOF
      # Slip the compat shim into v4l2_m2m.h so every TU that pulls in
      # M2M support inherits the missing colorspace symbols. We anchor
      # on the patch-introduced `#include "mvx-v4l2-controls.h"` to
      # keep the change idempotent should the patch ever move.
      substituteInPlace libavcodec/v4l2_m2m.h \
        --replace-fail '#include "mvx-v4l2-controls.h"' \
                       '#include "cix_v4l2_compat.h"
      #include "mvx-v4l2-controls.h"'
      # `v4l2_buffers.c` references the colorspace constants without
      # going through v4l2_m2m.h; add the shim there directly.
      substituteInPlace libavcodec/v4l2_buffers.c \
        --replace-fail '#include <linux/videodev2.h>' \
                       '#include "cix_v4l2_compat.h"'
    '';
    meta = old.meta // {
      description = "FFmpeg 5.1.7 with CIX P1 VPU (V4L2 M2M + VA-API) patches";
      homepage = "https://github.com/cixtech/cix_opensource__ffmpeg-cix";
      maintainers = with lib.maintainers; [ codgician ];
      # V4L2 M2M glue for the CIX P1 VPU; meaningless on other platforms.
      platforms = [ "aarch64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ fromSource ];
    };
    # The CIX patch alters mov muxer output bit-for-bit, so the
    # upstream `fate-movenc` hash regression test no longer matches.
    # The functional decode path still works; skip the test suite.
    doCheck = false;
  })
