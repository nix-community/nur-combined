self: super: {
  sc-im = super.sc-im.overrideAttrs (old: {
    buildPhase = ''
      cd src
      sed -i Makefile -e 's@\...name.info@.local/state/$(name)info@'
      cd ..
      '' + old.buildPhase;
  });
}
