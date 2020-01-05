{ pkgs }:

{

  gap-pygments-lexer.meta.broken = true;

} // (if pkgs.stdenv.isLinux then {

  apfs-fuse = pkgs.callPackage ./os-specific/linux/apfs-fuse {
    fuse = pkgs.fuse3;
  };

} else {})
