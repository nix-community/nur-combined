{ lib, ... }:
let
  f = lib.mkForce false;
in
{
  vacu.packages = {
    libreoffice.enable = f;
    ungoogled-chromium.enable = f;
    calibre.enable = f;
    merkaartor.enable = f;
    audacity.enable = f;
  };
}
