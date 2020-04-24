self: super: rec {
  postgresql_pam = super.postgresql_11.overrideAttrs(old: {
    # datadir in /var/lib/postgresql is named after psqlSchema
    passthru = old.passthru // { psqlSchema = "11.0"; };
    configureFlags = old.configureFlags ++ [ "--with-pam" ];
    buildInputs = (old.buildInputs or []) ++ [ self.pam ];
  });
}
