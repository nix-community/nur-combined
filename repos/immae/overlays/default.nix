{
  mylibs = self: super: { mylibs = import ../lib { pkgs = self; }; };
  mypkgs = self: super: import ../pkgs { pkgs = self; };

  bitlbee = import ./bitlbee;
  bitlbee-discord = import ./bitlbee-discord;
  bonfire = import ./bonfire;
  bundix = import ./bundix;
  dwm = import ./dwm;
  elinks = import ./elinks;
  gitweb = import ./gitweb;
  goaccess = import ./goaccess;
  kanboard = import ./kanboard;
  ldapvi = import ./ldapvi;
  lesspipe = import ./lesspipe;
  mysql = import ./databases/mysql;
  nixops = import ./nixops;
  pass = import ./pass;
  pelican = import ./pelican;
  postfix = import ./postfix;
  postgresql = import ./databases/postgresql;
  sc-im = import ./sc-im;
  shaarli = import ./shaarli;
  slrn = import ./slrn;
  taskwarrior = import ./taskwarrior;
  vcsh = import ./vcsh;
  weboob = import ./weboob;
  weechat = import ./weechat;
  ympd = import ./ympd;
  doing = import ./doing;
  xmr-stak = import ./xmr-stak;
  vdirsyncer = import ./vdirsyncer;
  msmtp = import ./msmtp;
}
// import ./python-packages
