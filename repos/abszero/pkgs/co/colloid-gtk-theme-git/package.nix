{ lib, colloid-gtk-theme, fetchFromGitHub }:

let lock = lib.importJSON ./lock.json; in

colloid-gtk-theme.overrideAttrs (prev: {
  version = lock.rev;
  src = fetchFromGitHub lock;
})
