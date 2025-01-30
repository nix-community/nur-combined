let
  common = {
    "10.0.1.1" = [ "nodens.nyaw.xyz" ];
    "10.0.2.1" = [ "azasos.nyaw.xyz" ];
    "10.0.3.1" = [ "abhoth.nyaw.xyz" ];
    "10.0.4.1" = [ "yidhra.nyaw.xyz" ];
  };

  srvOnEihort = [
    "eihort.nyaw.xyz"
    "matrix.nyaw.xyz"
    "photo.nyaw.xyz"
    "s3.nyaw.xyz"
  ];

  lan = {
    "192.168.1.16" = srvOnEihort;
    "192.168.1.2" = [
      "hastur.nyaw.xyz"
    ];
    "192.168.1.187" = [ "kaambl.nyaw.xyz" ];
  };

  remote = {
    "10.0.4.6" = srvOnEihort;
    "10.0.4.2" = [
      "hastur.nyaw.xyz"
    ];
    "10.0.2.3" = [ "kaambl.nyaw.xyz" ];
  };

  sum = lan // common;
in
{
  kaambl = {
    "127.0.0.1" = [
      "kaambl.nyaw.xyz"
      "dns.nyaw.xyz"
    ];
  } // sum;
  hastur = {
    "127.0.0.1" = [
      "hastur.nyaw.xyz"
    ];
  } // sum;
  eihort = {
  } // sum;
}
