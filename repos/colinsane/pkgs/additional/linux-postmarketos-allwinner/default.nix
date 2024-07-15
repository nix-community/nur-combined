{ lib
, fetchurl
, linux-megous
, linuxManualConfig
, sane-kernel-tools
, writeTextFile
#v nixpkgs calls `.override` on the kernel to configure additional things, but we don't care about those things
, features ? null
, kernelPatches ? null
, randstructSeed ? ""
, withModemPower ? false
}:

# keep in sync with linux-megous
# to update: bump the `pmaportsRef` commit, null the hash in pmPatch, and `wget https://gitlab.com/postmarketOS/pmaports/-/raw/$pmaportsRef/device/main/linux-postmarketos-allwinner/config-postmarketos-allwinner.aarch64`
let
  pmaportsRef = "982799b9a83259b59b25a41e19ca591e63ae9062";
  pmPatch = { name, hash ? "" }: {
    inherit name;
    patch = fetchurl {
      url = "https://gitlab.com/postmarketOS/pmaports/-/raw/${pmaportsRef}/device/main/linux-postmarketos-allwinner/${name}.patch";
      inherit hash;
    };
  };

  defconfigStr = (builtins.readFile ./config-postmarketos-allwinner.aarch64) + ''
    #
    # Extra nixpkgs-specific options
    # nixos/modules/system/boot/systemd.nix wants CONFIG_DMIID
    # nixos/modules/services/networking/firewall-iptables.nix wants CONFIG_IP_NF_MATCH_RPFILTER
    #
    CONFIG_DMIID=y
    CONFIG_IP_NF_MATCH_RPFILTER=y

    #
    # Extra sane-specific options
    #
    CONFIG_SECURITY_LANDLOCK=y
    CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf";
  '' + lib.optionalString withModemPower ''
    CONFIG_MODEM_POWER=y
  '';

in linuxManualConfig {
  inherit (linux-megous) extraMakeFlags modDirVersion src version;
  inherit randstructSeed;
  # inherit (linux-megou) kernelPatches;

  configfile = writeTextFile {
    name = "config-postmarketos-allwinner.aarch64";
    text = defconfigStr;
  };
  # nixpkgs requires to know the config as an attrset, to do various eval-time assertions.
  # this forces me to include the defconfig inline, instead of fetching it the way i do all the other pmOS kernel stuff.
  config = sane-kernel-tools.parseDefconfig defconfigStr;

  # these likely aren't *all* required for pinephone: pmOS kernel is shared by many devices
  kernelPatches = [
    (pmPatch {
      name = "0001-dts-add-dontbeevil-pinephone-devkit";
      hash = "sha256-GpJDuS5vzGrT8ybSEl0s/+vPblr917qusOA3aRWcmoA=";
    })
    (pmPatch {
      name = "0002-dts-add-pinetab-dev-old-display-panel";
      hash = "sha256-e+bTJgycI0DOYVaskHXd/OuazwZxlfu0yWzVlGxipvo=";
    })
    (pmPatch {
      name = "0003-dts-pinetab-add-missing-ohci1";
      hash = "sha256-aCxglJo4oZafKxp2Mjs+AIB8vWBUNvvTuBugQVlBu1A=";
    })
    (pmPatch {
      name = "0004-dts-pinetab-make-audio-routing-consistent-with-pinep";
      hash = "sha256-0R69silFsQkkgNIcSo4iKjhFzXTGQLma6fZSwAwSj3s=";
    })
  ] ++ lib.optionals (!withModemPower) [
    (pmPatch {
      name = "0005-dts-pinephone-drop-modem-power-node";
      hash = "sha256-59PdMo3hTfSh12pTIG/VzTSrsDQdK18nh+oCtnxvo50=";
    })
  ] ++ [
    (pmPatch {
      name = "0006-drm-panel-simple-Add-Hannstar-TQTM070CB501";
      hash = "sha256-KysfuhXwpSBUgdD2xd1IqbFdNz0GiGtFbP1xD5BeBPI=";
    })
    (pmPatch {
      name = "0007-ARM-dts-sun6i-Add-GoClever-Orion-70L-tablet";
      hash = "sha256-iGy2oQgxa8HxaulsDWcAKCUG/ygK7gsL0gPyLUcDLAI=";
    })
    (pmPatch {
      name = "0008-drm-panel-simple-Add-Hannstar-HSD070IDW1-A";
      hash = "sha256-xdQh7z2Xn45Ku6c5xqsmYdFPutrjkRTi+nf7jKluu74=";
    })
    (pmPatch {
      name = "0009-ARM-dts-sun6i-Add-Lark-FreeMe-70.2S-tablet";
      hash = "sha256-c3xrtlmSQwEHt/XkjXHHvxO9ff6S34SGxtiej6zddgw=";
    })
    (pmPatch {
      name = "0010-eMMC-workaround";
      hash = "sha256-JXFCBAIBejhGdMSNef5HViGmJZ1RJsc8d++ioTVrjkI=";
    })
    (pmPatch {
      name = "0011-arm64-dts-allwinner-orangepi-3-fix-ethernet";
      hash = "sha256-vqZwlMFQhmA8AUfQDwi9lAHpPhtFaOrf+KgHgfBGWgQ=";
    })
    (pmPatch {
      name = "0012-ARM-dts-allwinner-sun5i-a13-pocketbook-614-plus-Add-";
      hash = "sha256-ZGMfbVr7s6zESC/BFwozHcJgRbF+xInzLkQaAWlfJ9w=";
    })
    {
      name = "pinephone-1.2b-add-af8133j-magnetometer";
      patch = linux-megous.passthruPatches.af8133j;
    }
  ];
}
