final: super: {
  libxml2 = super.libxml2.overrideAttrs (old: {
    configureFlags = (old.configureFlags or [ ]) ++ [ "--with-schematron" ];
  });
}
