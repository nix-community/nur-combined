let
  common = {
    "10.0.1.1" = [ "nodens.nyaw.xyz" ];
    "10.0.2.1" = [ "azasos.nyaw.xyz" ];
    "10.0.3.1" = [ "abhoth.nyaw.xyz" ];
    "10.0.4.1" = [ "yidhra.nyaw.xyz" ];
  };
in
{
  kaambl = {
    "127.0.0.1" = [
      "kaambl.nyaw.xyz"
      "dns.nyaw.xyz"
    ];
    # "10.0.4.6" = [
    #   "eihort.nyaw.xyz"
    #   "photo.nyaw.xyz"
    #   "s3.nyaw.xyz"
    # ];

    "192.168.1.16" = [
      "eihort.nyaw.xyz"
      "photo.nyaw.xyz"
      "s3.nyaw.xyz"
    ];

    "10.0.4.2" = [
      "hastur.nyaw.xyz"
    ];
  } // common;
  hastur = {
    "127.0.0.1" = [
      "hastur.nyaw.xyz"
    ];
    "10.0.4.3" = [ "kaambl.nyaw.xyz" ];
    "192.168.1.16" = [
      "eihort.nyaw.xyz"
      "photo.nyaw.xyz"
    ];
    "10.0.4.6" = [
      "s3.nyaw.xyz"
    ];
  } // common;
  eihort = {
    "127.0.0.1" = [
      "eihort.nyaw.xyz"
      "s3.nyaw.xyz"
    ];
    "10.0.4.6" = [
      "photo.nyaw.xyz"
      "eihort.nyaw.xyz"
      "s3.nyaw.xyz"
    ];
    "10.0.2.3" = [ "kaambl.nyaw.xyz" ];
    "192.168.1.2" = [ "hastur.nyaw.xyz" ];
  } // common;
}
