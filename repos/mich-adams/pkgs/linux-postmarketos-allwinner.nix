{
  lib,
  fetchurl,
  fetchFromGitea,
  fetchFromGitLab,
  linuxManualConfig,
  writeTextFile,
  features ? null,
  kernelPatches ? null,
  randstructSeed ? "",
}:

let
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "63cd5bebb91fc46e1bf4d3b9fa6457cd66483e11";
    hash = "sha256-CS2jZRQaXMiG1CSvCN32aobb6aR0NuRhq/dw4JNPW0Y=";
  };
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "megi";
    repo = "linux";
    rev = "orange-pi-6.17-20251026-1441";
    hash = "sha256-SoHvTjmdZb2m3tY5pK60d64d35wc5apOiYzzep3X7wM=";
  };
  version = "6.17.5";
  modDirVersion = "6.17.5";
  pmPatch = name: {
    inherit name;
    patch = "${pmaports}/device/community/linux-postmarketos-allwinner/${name}.patch";
  };
  defconfigStr =
	(builtins.readFile "${pmaports}/device/community/linux-postmarketos-allwinner/config-postmarketos-allwinner.aarch64")
    + ''
      #
      # Extra nixpkgs-specific options
      # nixos/modules/system/boot/systemd.nix wants CONFIG_DMIID
      # nixos/modules/services/networking/firewall-iptables.nix wants CONFIG_IP_NF_MATCH_RPFILTER
      # Jumpdrive has CONFIG_AXP288_FUEL_GAUGE set to yes
      #
      CONFIG_DMIID=y
      CONFIG_IP_NF_MATCH_RPFILTER=y
      CONFIG_DEBUG_INFO_BTF=n
    '';

in
(linuxManualConfig {
  inherit
    src
    version
    modDirVersion
    randstructSeed
    ;

  configfile = writeTextFile {
    name = "config-postmarketos-allwinner.aarch64";
    text = defconfigStr;
  };

  kernelPatches = [
    (pmPatch "0001-dts-add-dontbeevil-pinephone-devkit")
    (pmPatch "0002-dts-add-pinetab-dev-old-display-panel")
    (pmPatch "0003-dts-pinetab-add-missing-ohci1")
    (pmPatch "0004-dts-pinetab-make-audio-routing-consistent-with-pinep")
    (pmPatch "0005-dts-pinephone-drop-modem-power-node")
    (pmPatch "0006-drm-panel-simple-Add-Hannstar-TQTM070CB501")
    (pmPatch "0007-ARM-dts-sun6i-Add-GoClever-Orion-70L-tablet")
    (pmPatch "0008-drm-panel-simple-Add-Hannstar-HSD070IDW1-A")
    (pmPatch "0009-ARM-dts-sun6i-Add-Lark-FreeMe-70.2S-tablet")
    (pmPatch "0010-eMMC-workaround")
    (pmPatch "0011-arm64-dts-allwinner-orangepi-3-fix-ethernet")
    {
      name = "fix-display";
      patch = null;
      extraConfig = ''
        DRM m
      '';
    }
        {
      name = "disable-bpf";
      patch = null;
      extraConfig = ''
        DEBUG_INFO_BTF n
        CONFIG_DEBUG_INFO_BTF n
      '';
    }
  ];

}).overrideAttrs
  (base: {
    passthru = (base.passthru or { }) // {
      inherit defconfigStr;
    };
  })
