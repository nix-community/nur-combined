{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Xbox Wireless Controller (Series 1914) drops are often due to RTL8761BU
  # firmware bugs. We override with the 'rtk1395' blob (repackaged by
  # andrew-ld to be direct-loaded) to bypass the stock broken blob.
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "rtl8761bu-custom-firmware";
      version = "4b36bce";
      src = pkgs.fetchFromGitHub {
        owner = "andrew-ld";
        repo = "rtl8761b-firmware";
        rev = "4b36bce18a5c9162d0c4f63ff70abcc5e9db9e28";
        sha256 = "1qi4vnwfx128dh99kpn2k0yqvy24i8wqq1q57pv7k6lad5w7nc74";
      };
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/lib/firmware/rtl_bt
        cp rtl8761bu_fw.bin $out/lib/firmware/rtl_bt/
        cp rtl8761bu_config.bin $out/lib/firmware/rtl_bt/
      '';
    })
  ];

  # Standard community fix: Disable ERTM to prevent disconnect loops
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=y
  '';
}
