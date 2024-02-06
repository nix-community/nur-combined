{ ... }: {
  accounts.email.accounts."eownerdead@disroot.org" = {
    address = "eownerdead@disroot.org";
    userName = "eownerdead@disroot.org";
    realName = "EOWNERDEAD";
    primary = true;
    imap.host = "disroot.org";
    smtp.host = "disroot.org";
    gpg = {
      encryptByDefault = true;
      signByDefault = true;
      key = "009E56305CA54D63";
    };
  };
}

