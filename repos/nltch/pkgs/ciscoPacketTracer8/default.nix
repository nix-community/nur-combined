{ pkgs, lib, ... }:

pkgs.ciscoPacketTracer8.overrideAttrs (prev: {
    src = pkgs.fetchurl {
        # https://nc-9064872931098112376.nextcloud-ionos.com/index.php/s/eKymgjnX3MYgFNF fast private link (for public use)
        # https://archive.org/download/cisco-packet-tracer-820-ubuntu-64bit/CiscoPacketTracer_820_Ubuntu_64bit.deb slow public link
        url = "https://nc-9064872931098112376.nextcloud-ionos.com/index.php/s/eKymgjnX3MYgFNF/download/CiscoPacketTracer_820_Ubuntu_64bit.deb";
        sha256 = "1b19885d59f6130ee55414fb02e211a1773460689db38bfd1ac7f0d45117ed16";
    };
})