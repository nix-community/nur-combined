self: super: {
  neomutt = super.neomutt.overrideAttrs (old:
    {
      buildInputs = old.buildInputs ++ [ self.gdbm ];
      configureFlags = old.configureFlags ++ [ "--gdbm" ];
    }
  );
}
