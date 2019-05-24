self: super: {
  nixops = super.nixops.overrideAttrs (old: {
    preConfigure = (old.preConfigure or "") + ''
      sed -i -e "/'keyFile'/s/'path'/'string'/" nixops/backends/__init__.py
      '';
  });
}
