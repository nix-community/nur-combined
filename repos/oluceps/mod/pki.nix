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
          # caCertificateBlacklist = [
          #   "CNNIC ROOT"
          #   "CNNIC SSL"
          #   "China Internet Network Information Center EV Certificates Root"
          #   "WoSign"
          #   "WoSign China"
          #   "CA WoSign ECC Root"
          #   "Certification Authority of WoSign G2"
          # ];
        };
      };

    };
}
