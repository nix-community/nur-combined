self: super: {
  lesspipe = super.lesspipe.overrideAttrs(old: {
    configureFlags = (old.configureFlags or []) ++ [ "--yes" ];
  });
}
