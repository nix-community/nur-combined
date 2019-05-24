self: super: {
  dwm = super.dwm.overrideAttrs(old: rec {
    postPatch = ''
      cp ${./dwm_config.h} ./config.h
      '';
  });
}
