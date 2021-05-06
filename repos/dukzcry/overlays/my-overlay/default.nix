{ unstable, config }:

self: super:
{
  haskellPackages = super.haskellPackages.override {
    overrides = hsSelf: hsSuper: {
      hakyll-images = self.haskell.lib.unmarkBroken hsSuper.hakyll-images;
    };
  };
  # https://github.com/qutebrowser/qutebrowser/pull/5917
  qutebrowser = (unstable.qutebrowser.override {
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
  }).overrideAttrs (oldAttrs: {
    postFixup = ''
      ${oldAttrs.postFixup}
      wrapProgram $out/bin/qutebrowser \
        --prefix PATH : "${super.stdenv.lib.makeBinPath [ super.mpv ]}"
    '';
  });
  wifi-killer = with super; writeShellScriptBin "wifi-killer" ''
    pciid=02:00.0
    echo 1 > /sys/bus/pci/devices/0000:$pciid/remove
    sleep 5
    rmmod iwlmvm iwlwifi
    sleep 5
    echo 1 > /sys/bus/pci/rescan
    sleep 5
    modprobe iwlwifi iwlmvm
  '';
}
