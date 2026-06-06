{
  stdenv,
  callPackage,
  opencv4,
}:

# darwin（仅 Apple Silicon）走官方 mac .app（darwin.nix）；
# linux 走自打包的 wayland 原生版（linux.nix）。
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix { }
else
  callPackage ./linux.nix {
    opencv4 = opencv4.override {
      # ── BUILD_LIST: only core + imgproc ──────────────────────────
      enabledModules = [
        "core"
        "imgproc"
      ];

      # ── Image codecs (all off — core/imgproc don't need them) ───
      enableJPEG = false;
      enablePNG = false;
      enableTIFF = false;
      enableWebP = false;
      enableEXR = false;
      enableJPEG2000 = false;

      # ── Contrib modules ─────────────────────────────────────────
      enableContrib = false;
      enableTesseract = false; # also gates contrib build
      enableOvis = false; # also gates contrib build

      # ── Math / acceleration ─────────────────────────────────────
      enableEigen = false;
      enableBlas = false;
      enableLto = false; # harmless, only affects compiler flags
      enableIpp = false; # Intel IPP (already default false)
      enableTbb = false; # Intel TBB

      # ── GPU (CUDA) ──────────────────────────────────────────────
      enableCuda = false;
      enableCublas = false;
      enableCudnn = false;
      enableCufft = false;

      # ── Video / camera / media I/O ──────────────────────────────
      enableFfmpeg = false;
      enableGStreamer = false;
      enableVA = false; # VA-API video acceleration
      enableGPhoto2 = false; # digital camera support
      enableDC1394 = false; # FireWire camera

      # ── GUI ─────────────────────────────────────────────────────
      enableGtk2 = false;
      enableGtk3 = false;
      enableVtk = false;

      # ── Python bindings ─────────────────────────────────────────
      enablePython = false;

      # ── Docs ────────────────────────────────────────────────────
      enableDocs = false;

      # ── Non-free algorithms ─────────────────────────────────────
      enableUnfree = false;

      # ── Tests (skip hdf5 + test data fetch) ─────────────────────
      runAccuracyTests = false;
      runPerformanceTests = false;
    };
  }
