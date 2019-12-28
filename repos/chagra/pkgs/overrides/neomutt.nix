with import <nixpkgs> {};

neomutt.overrideAttrs ( oldAttrs: {
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
})
