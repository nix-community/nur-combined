final: prev:
with final; let
  inputs = prev.inputs;

  pkg_from_flake = pkg:
    prev.${pkg}.overrideAttrs (o: {
      src = inputs."${pkg}-src";
      version = "${lib.substring 0 8 (inputs."${pkg}-src".lastModifiedDate or inputs."${pkg}-src".lastModified or "19700101")}.${inputs."${pkg}-src".shortRev or "dirty"}";
      patches = [];
    });
in {
  swayidle = prev.swayidle.overrideAttrs (o: {
    postPatch =
      (o.postPatch or "")
      + ''
        sed -i -e 's@"sh"@"${bash}/bin/bash"@' main.c
      '';
  });
  # Patch libvirt to use ebtables-legacy
  libvirt =
    if prev.libvirt.version <= "5.4.0" && prev.ebtables.version > "2.0.10-4"
    then
      prev.libvirt.overrideAttrs
      (oldAttrs: rec {
        EBTABLES_PATH = "${final.ebtables}/bin/ebtables-legacy";
      })
    else prev.libvirt;

  install-script = drv:
    with final;
      writeScript "install-${drv.name}"
      ''        #!/usr/bin/env bash
              set -x

              nixos-install --system ${drv} $@

              umount -R /mnt
              zfs set mountpoint=legacy bt580/nixos
              zfs set mountpoint=legacy rt580/tmp
      '';

  dwm = (pkg_from_flake "dwm").overrideAttrs (_: {
    patches = [];
  });
  st = (pkg_from_flake "st").overrideAttrs (_: {
    patches = [];
  });
  mako = pkg_from_flake "mako";
  dwl =
    ((pkg_from_flake "dwl").override {
      /*
      wlroots = wlroots_0_16;
      */
    })
    .overrideAttrs (o: {
      buildInputs =
        o.buildInputs
        ++ [
          xorg.xcbutilwm
        ];
    });
}
