{
  mylibs = self: super: { mylibs = import ../lib { pkgs = self; }; };
  mypkgs = self: super: import ../pkgs { pkgs = self; };

  bitlbee = import ./bitlbee;
  bundix = import ./bundix;
  dwm = import ./dwm;
  elinks = import ./elinks;
  gitweb = import ./gitweb;
  goaccess = import ./goaccess;
  kanboard = import ./kanboard;
  ldapvi = import ./ldapvi;
  lesspipe = import ./lesspipe;
  mysql = import ./databases/mysql;
  neomutt = import ./neomutt;
  nixops = import ./nixops;
  pass = import ./pass;
  pelican = import ./pelican;
  postgresql = import ./databases/postgresql;
  profanity = import ./profanity;
  sc-im = import ./sc-im;
  shaarli = import ./shaarli;
  slrn = import ./slrn;
  taskwarrior = import ./taskwarrior;
  vit = import ./vit;
  weboob = import ./weboob;
  weechat = import ./weechat;
  ympd = import ./ympd;
}
// import ./python-packages
// import ./environments
