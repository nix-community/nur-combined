{
  self,
  lib,
  pkgs,
  ...
}:
let
  ignoreList = [
    "iso"
    "host-pxe-installer"
    "host-pxe-installer-aarch64"
    "pxe-initrd"
  ];
  # We don't want iso/img derivations here because they de-dupe terribly. Any change anywhere requires generating a new iso/img file.
  isoContentsStr = lib.concatStringsSep "\n" (
    map (
      c: "${c.source} => ${c.target}"
    ) self.nixosConfigurations.shel-installer-iso.config.isoImage.contents
  );
  isoContents = pkgs.writeText "iso-contents" isoContentsStr;
  pxeConfig = self.nixosConfigurations.shel-installer-pxe.config;
  pxeContents = pkgs.linkFarm "pxe-initrd-contents" {
    inherit (pxeConfig.boot.initrd) compressor;
    inherit (pxeConfig.system.build) initialRamdisk;
    storeContents = pkgs.linkFarmFromDrvs "store-contents" pxeConfig.netboot.storeContents;
  };
  extraBuilds = { inherit isoContents pxeContents; };
  buildListWithout = builtins.filter (v: !builtins.elem v ignoreList) (
    builtins.attrNames self.buildList
  );
  allBuilds = self.buildList // extraBuilds;
in
rec {
  archiveList = map (name: {
    inherit name;
    broken = builtins.elem name self.brokenBuilds;
    impure = builtins.elem name self.impureBuilds;
  }) (buildListWithout ++ builtins.attrNames extraBuilds);

  drvs = allBuilds;
  buildDepsDrvs = builtins.mapAttrs (_: v: pkgs.closureInfo { rootPaths = [ v.drvPath ]; }) drvs;
}
