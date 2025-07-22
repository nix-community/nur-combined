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
}@args:

let
  pmaports = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "b80d00118d5094e2ad0318866ded8d7907ec363d";
    hash = "sha256-v6/s0JhFFCEqQkhg5xTWGCx+7Z1UvPjtJi0/otZIObg=";
  };
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "megi";
    repo = "linux";
    rev = "c0c8fa8103dfc8577711f70cc4434773c33c2970";
    hash = "sha256-d+89Lu4stkLnI/W/07VEVFPUhG0fXgSDBwvJKiFmPvM=";
  };
  version = "6.15.6";
  modDirVersion = "6.15.6";
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
  allowImportFromDerivation = true;
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
