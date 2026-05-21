{pkgs, ...}:
pkgs.linuxPackages_latest.kernel.override {
  kernelPatches = [
    {
      name = "Bluetooth: btmtk: accept too short WMT FUNC_CTRL events";
      patch = pkgs.fetchurl {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next.git/patch/?id=162b1adeb057d28ad84fd8a03f3c50cf08db5c62";
        hash = "sha256-ij0hQmC0U++AdXWQy6nycnDe6z4yaMoQIrSiLal5DHc=";
      };
    }
  ];
}
