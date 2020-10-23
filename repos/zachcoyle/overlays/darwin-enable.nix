self: super: {

  dateutils = super.dateutils.overrideAttrs (oldAttrs: {
    meta = with super.stdenv.lib.platforms; {
      platforms = linux ++ darwin;
    };
  });

}
