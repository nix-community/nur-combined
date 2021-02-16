{ config, pkgs, ... }:
{
    services.grocy = {
        enable = true;
        hostName = "grocy.samhatfield.me";
    };
}