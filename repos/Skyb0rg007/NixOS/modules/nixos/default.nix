{ lib, packagesFor }:
{
  blueferry = ./blueferry;
  dnclient = ./dnclient;
  credentialsd = lib.modules.importApply ./credentialsd { inherit packagesFor; };
  cascade = ./cascade;
  debspawn = ./debspawn;
  dell-command-monitor = ./dell-command-monitor;
  keepassxc = ./keepassxc;
  keylime = ./keylime;
  tubearchivist = ./tubearchivist;
  ublksrv = ./ublksrv;
}
