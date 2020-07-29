{ elm }:
elm.overrideAttrs (_ : {
  patches = [./0001-update-kernel-permissions.patch];
})
