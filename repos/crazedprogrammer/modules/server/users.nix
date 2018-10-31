{ config, pkgs, lib, ... }:

with import ./vars.nix;

{
  security = {
    sudo.wheelNeedsPassword = false;
    pam.loginLimits = [
      { domain = "lur"; item = "nofile"; type = "-"; value = "10000000"; }
    ];
  };

  users.mutableUsers = false;
  users.groups = { media = { }; };
  users.extraUsers = {
    casper = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "media" ];
      hashedPassword = builtins.readFile ../../../.casper-passwd;
      home = "/home/casper";
      shell = pkgs.fish;
    };
    unp = {
      isNormalUser = true;
      uid = 1007;
      description = "Generic unprivileged user";
      home = "/home/unp";
    };
    # Media users
    media = {
      uid = 1008;
      description = "Main media user";
      group = "media";
      home = mediaHome;
      isNormalUser = true;
      openssh.authorizedKeys.keys = authorizedKeys;
    };
    ccfuse = {
      uid = 1009;
      description = "CCFuse user";
      home = ccfuseHome;
      createHome = true;
      isNormalUser = true;
      openssh.authorizedKeys.keys = authorizedKeys;
    };

    # Application-specific users
    c3i = {
      uid = 1002;
      description = "c3i user";
      home = c3iHome;
      createHome = true;
    };
    shittydl = {
      uid = 1003;
      description = "shittydl user";
      home = shittydlHome;
      createHome = true;
    };
    thelounge = {
      uid = 1004;
      description = "The Lounge daemon user";
      home = theloungeHome;
      createHome = true;
    };
    jamrogue = {
      uid = 1005;
      description = "Jamrogue server user";
      home = jamrogueHome;
      createHome = true;
    };
    modmc1 = {
      uid = 1006;
      description = "Minecraft modded server";
      home = modmc1Home;
      createHome = true;
    };
  };
}
