{
  pkgs,
}:
let
  inherit (import ../../../private.nix { inherit pkgs; }) nodarwin v3overridegcc;
in
nodarwin (
  v3overridegcc (
    pkgs.grub2.overrideAttrs (old: {
      pname = "grub2-patched";
      patches = (old.patches or [ ]) ++ [ ./grub-os-prober-title.patch ];
    })
  )
)
