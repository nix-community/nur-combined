{ callPackage }:

{
  deu-eng = callPackage ./base.nix {
    lang = "deu-eng";
    version = "0.3.5";
    sha256 = "0sy68l3433pqsssyg2gnsjhcvjb7bn658hkwkd9rpf3m0jic9lgm";
  };
  epo-eng = callPackage ./base.nix {
    lang = "epo-eng";
    version = "1.0.1";
    sha256 = "095xwqfc43dnm0g74i83lg03542f064jy2xbn3qnjxiwysz9ksnz";
  };
  fin-eng = callPackage ./base.nix {
    lang = "fin-eng";
    version = "2020.02.08";
    sha256 = "036ai6avh5xq5f0bi8rzykc44rrqir71xw40w44fwknfd814jjh7";
  };
}
