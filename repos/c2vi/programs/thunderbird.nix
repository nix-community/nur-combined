{ pkgs, config, persistentDir, ... }: {

  ## thunderbird settings
  programs.thunderbird = {
    enable = true;

    profiles.me = {
      isDefault = true;
    };
  };

  ## mail archiveing...


  ## email accounts
  /*
  accounts.email.accounts.sewi-gmail = {
   flavor = "gmail.com";
  };

  accounts.email.accounts.c2vi-gmail = {
   flavor = "gmail.com";
  };
  */


  /*
  # not working....
  home.file.".thunderbird" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/thunderbird";
  };
  */

}

