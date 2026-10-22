# Non-LTO x86-64-v3 kernel, built with the repository nixpkgs (flake.lock).
# callPackage owns override; forward NixOS kernel arguments to our constructor.
{ lib, pkgs, ... }@args:
let
  kernel = import ../../lib/cachyos (
    {
      pname = "linux-cachyos-bore-x86_64-v3";
      variant = "linux-cachyos-bore";
      source = builtins.fromJSON (builtins.readFile ./source.json);
    }
    // builtins.removeAttrs args [ "lib" ]
  );
in
lib.addMetaAttrs {
  ciBuild = false;
  description = "Linux CachyOS BORE kernel for x86-64-v3 (non-LTO)";
  homepage = "https://github.com/CachyOS/linux-cachyos";
  license = lib.licenses.gpl2Only;
  platforms = [ "x86_64-linux" ];
} kernel
