{
  lib,
  fetchurl,
  runCommand,
  unzip,
}:

let
  mkImageBundle =
    {
      pname,
      version,
      systemUrl,
      systemHash,
      vendorUrl,
      vendorHash,
    }:
    runCommand "${pname}-${version}"
      {
        nativeBuildInputs = [ unzip ];
        meta = {
          description = "Prebuilt Android system and vendor image bundle for Miodroid";
          license = lib.licenses.asl20;
          platforms = [ "x86_64-linux" ];
        };
      }
      ''
        mkdir -p "$out"
        unzip -j ${
          fetchurl {
            url = systemUrl;
            hash = systemHash;
          }
        } system.img -d "$out"
        unzip -j ${
          fetchurl {
            url = vendorUrl;
            hash = vendorHash;
          }
        } vendor.img -d "$out"
      '';

  a13 = mkImageBundle {
    pname = "miodroid-a13-robotnix";
    version = "20260927";
    systemUrl = "https://sourceforge.net/projects/waydroid/files/images/system/lineage/waydroid_x86_64/lineage-20.0-20260927-VANILLA-waydroid_x86_64-system.zip/download";
    systemHash = "sha256-BTVSclv0riXi0/fm8ZRyAylKqdc9wX/h86vmRuXTvYo=";
    vendorUrl = "https://sourceforge.net/projects/waydroid/files/images/vendor/waydroid_x86_64/lineage-20.0-20260927-MAINLINE-waydroid_x86_64-vendor.zip/download";
    vendorHash = "sha256-2RG4NT9sgHuUeQscQcZ+hjqfPc0c8+wCMjUTmCNa/Xo=";
  };

  a16 = mkImageBundle {
    pname = "miodroid-a16-robotnix";
    version = "20260717";
    systemUrl = "https://github.com/WayDroid-ATV/waydroid-builds/releases/download/20260717/lineage-23.2-20260717-VANILLA-waydroid_x86_64-system.zip";
    systemHash = "sha256-FS4PXAHPEMxMfsk3I8KGMIoGyxM05u60pAOcs0X5euQ=";
    vendorUrl = "https://github.com/WayDroid-ATV/waydroid-builds/releases/download/20260717/lineage-23.2-20260717-MAINLINE-waydroid_x86_64-vendor.zip";
    vendorHash = "sha256-KN+9DkI9/21cfS404VAR+69IZdp2nZkjuEZW2H6fTTw=";
  };
in
a16.overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // {
    inherit a13 a16;
  };
})
