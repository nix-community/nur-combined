{
  pkgs ? import <nixpkgs> { },
}:
pkgs.pkgsCross.armv7l-hf-multiplatform.pkgsStatic.bubblewrap.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./bwrap.patch ];
})
