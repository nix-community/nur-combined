{ pkgs, lib, ... }:

pkgs.ciscoPacketTracer8.overrideAttrs (prev: {
    src = pkgs.fetchurl {
        url = "https://github.com/NL-TCH/LFS-artifacts/raw/main/NIX/CiscoPacketTracer822_amd64_signed.deb";
        sha256 = "0bgplyi50m0dp1gfjgsgbh4dx2f01x44gp3gifnjqbgr3n4vilkc";
    };
})
