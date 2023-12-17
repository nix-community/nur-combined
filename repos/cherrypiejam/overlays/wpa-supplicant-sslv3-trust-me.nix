self: super: {
  # Princeton PEAP auth requires SSLv3
  wpa_supplicant = super.wpa_supplicant.overrideAttrs (o: {
    patches = (o.patches or []) ++ [
      ./0001-Enable-SSL_OP_LEGACY_SERVER_CONNECT.patch
    ];
  });
}
