{ config, pkgs, ... }:
{
    security.acme.certs."grocy.samhatfield.me".email = "hey@samhatfield.me";

    services.grocy = {
        enable = true;
        hostName = "grocy.samhatfield.me";
    };
}