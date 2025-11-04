(self: super: {
  # NixOS 23.05 links wpa_supplicant against OpenSSL v3, which
  # disables support for SSLv3, which in turn is required by the
  # Princeton PEAP authentication server.
  wpa_supplicant = super.wpa_supplicant.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      ./0001-Enable-SSL_OP_LEGACY_SERVER_CONNECT.patch
    ];
  });
})
