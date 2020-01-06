{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  #Actual Packages
  ueberzug = pkgs.callPackage ./pkgs/ueberzug { };
  nudoku = pkgs.callPackage ./pkgs/nudoku { };
  swayblocks = pkgs.callPackage ./pkgs/swayblocks { };
  cboard = pkgs.callPackage ./pkgs/cboard { };
  ripcord = pkgs.callPackage ./pkgs/ripcord { };
  ydotool = pkgs.callPackage ./pkgs/ydotool { };
  compton-tryone = pkgs.callPackage ./pkgs/compton-tryone { };


  #Overrides that Travis CI will build so I don't have to
  vimCustom = pkgs.callPackage ./pkgs/overrides/vim.nix { };
  zathura-poppler-only = pkgs.callPackage ./pkgs/overrides/zathurapoppler.nix { };

  wineWow = pkgs.wineStaging.override { wineBuild = "wineWow"; };
  ncmpcpp = pkgs.ncmpcpp.override { visualizerSupport = true; };
  neomutt = pkgs.neomutt.overrideAttrs ( oldAttrs: {
    buildInputs = with pkgs; [
      cyrus_sasl gss gpgme kerberos libidn ncurses
      openssl perl lmdb
      mailcap
    ];
    configureFlags = [
      "--gpgme"
      "--gss"
      "--lmdb"
      "--ssl"
      "--sasl"
      "--with-homespool=mailbox"
      "--with-mailpath="
      # Look in $PATH at runtime, instead of hardcoding /usr/bin/sendmail
      "ac_cv_path_SENDMAIL=sendmail"
    ];
  });
  notmuch = pkgs.notmuch.overrideAttrs ( oldAttrs: {
    buildInputs = with pkgs; [
      gnupg
      xapian gmime3 talloc zlib
      perl
      pythonPackages.python
    ];
    postPatch = ''
      patchShebangs configure
      patchShebangs test/

      substituteInPlace lib/Makefile.local \
        --replace '-install_name $(libdir)' "-install_name $out/lib"
    '';
    doCheck = false;
  });
}
