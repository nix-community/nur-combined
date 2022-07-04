{pkgs, ...}: {
  cosevka = pkgs.callPackage ./cosevka {};
  terminus-font-custom = pkgs.callPackage ./terminus-font-custom {};
  virt-manager = pkgs.callPackage ./virt-manager {};
}
