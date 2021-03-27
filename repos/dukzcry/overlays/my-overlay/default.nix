{ unstable, config }:

self: super:
{
  haskellPackages = super.haskellPackages.override {
    overrides = hsSelf: hsSuper: {
      hakyll-images = self.haskell.lib.unmarkBroken hsSuper.hakyll-images;
    };
  };
  nvidia-offload = with super; writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
  # https://github.com/qutebrowser/qutebrowser/pull/5917
  qutebrowser = unstable.qutebrowser.override {
    python3 = super.python3.override {
      packageOverrides = selfx: superx: {
        pyqtwebengine = superx.pyqtwebengine.overridePythonAttrs (oldAttrs: rec {
          src = superx.pythonPackages.fetchPypi {
            pname = "PyQtWebEngine";
            version = "5.15.2";
            sha256 = "0d56ak71r14w4f9r96vaj34qcn2rbln3s6ildvvyc707fjkzwwjd";
          };
        });
      };
    };
  };
  openmpt123 = super.openmpt123.override { usePulseAudio = config.nixpkgs.config.pulseaudio; };
}
