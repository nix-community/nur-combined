self: super: rec {
  mariadb = mariadbPAM;
  mariadbPAM = super.mariadb.overrideAttrs(old: {
    cmakeFlags = old.cmakeFlags ++ [ "-DWITH_AUTHENTICATION_PAM=ON" ];
    buildInputs = old.buildInputs ++ [ self.pam ];
  });
}
