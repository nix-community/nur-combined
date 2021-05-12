self: super: {
  libindicator-gtk3 = super.libindicator-gtk3.overrideAttrs(oldAttrs: {
    postPatch = oldAttrs.postPatch + ''
      substituteInPlace libindicator/indicator3-0.4.pc.in.in \
        --replace 'indicatordir=''${libdir}' 'indicatordir=/run/current-system/sw/lib'
    '';
  });

  onboard = super.onboard.overrideAttrs(oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ super.libappindicator-gtk3 ];
  });
}
