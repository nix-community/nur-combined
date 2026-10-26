{
  flake.modules.nixos.pki =
    { config, pkgs, ... }:
    {
      security = {
        pki = {
          certificateFiles = [
            "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            config.fn.pki.root_file
          ];
          caCertificateBlacklist = [
            # eMudhra Technologies Limited
            "emSign Root CA - G1"
            "emSign ECC Root CA - G3"

            # eMudhra Inc.
            "emSign Root CA - C1"
            "emSign ECC Root CA - C3"
          ];
        };
      };

    };
}
