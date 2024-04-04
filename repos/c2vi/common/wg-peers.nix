{ secretsDir, ... }: [
  #################### home ####################
  {
    name = "phone-pt";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-phone";
    allowedIPs = [ "10.1.1.3" ];
    endpoint = "192.168.44.1:51820";
    persistentKeepalive = 25;
  }
  {
    name = "phone-pw";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-phone";
    allowedIPs = [ "10.1.1.3" ];
    endpoint = "192.168.133.118:51820";
    persistentKeepalive = 25;
  }
  /*
  {
    name = "main-pw";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-main";
    allowedIPs = [ "10.1.1.11" ];
    endpoint = "192.168.20.11:51820";
    persistentKeepalive = 25;
  }
  {
    name = "main-pt";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-main";
    allowedIPs = [ "10.1.1.11" ];
    endpoint = "192.168.44.11:51820";
    persistentKeepalive = 25;
  }
  {
    name = "main-home";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-main";
    #allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.1.11:51820";
    persistentKeepalive = 25;
  }
  {
    name = "rpi-pt";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-rpi";
    #allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.44.2:49390";
    persistentKeepalive = 25;
  }
  {
    name = "rpi-local";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-rpi";
    #allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.1.2:49390";
    persistentKeepalive = 25;
  }
  {
    name = "rpi-web";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-rpi";
    #allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "c2vi.dev:49390";
    persistentKeepalive = 25;
  }

  /*
  {
    name = "main";
    publicKey = builtins.readFile "${secretsDir}"/wg-pub-main;
    allowedIPs = [ "10.1.1.2/24" ];
  }
  {
    name = "phone";
    publicKey = builtins.readFile "${secretsDir}"/wg-pub-phone;
    allowedIPs = [ "10.1.1.3/24" ];
  }
  {
    name = "hpm";
    publicKey  =builtins.readFile  "${secretsDir}"/wg-pub-hpm;
    allowedIPs = [ "10.1.1.6/24" ];
  }
  {
    name = "main";
    publicKey = builtins.readFile  "${secretsDir}"/wg-pub-main;
    allowedIPs = [ "10.1.1.2/24" ];
  }

  {
    name = "rpi";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-rpi";
    allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.1.2:49390, c2vi.dev:49389";
    persistentKeepalive = 25;
  }
  {
    name = "lush-local";
    publicKey = builtins.readFile "${secretsDir}/wg-pub-lush";
    allowedIPs = [ "10.1.1.0/24" ];
    endpoint = "192.168.5.5:51820";
    persistentKeepalive = 25;
  }
  */
]
/* the networkmanager config
let
  main-pub = builtins.readFile "${secretsDir}/wg-pub-main";
  rpi-pub = builtins.readFile "${secretsDir}/wg-pub-rpi";
  lush-pub = builtins.readFile "${secretsDir}/wg-pub-lush";
  hpm-pub = builtins.readFile "${secretsDir}/wg-pub-hpm";
  acern-pub = builtins.readFile "${secretsDir}/wg-pub-acern";
  phone-pub = builtins.readFile "${secretsDir}/wg-pub-phone";
in
{
  "wireguard-peer.${main-pub}" = {
    endpoint = "192.168.1.40:51820";
    persistent-keepalive = "25";
    allowed-ips = "0.0.0.0";
  };
  "wireguard-peer.${rpi-pub}" = {
    endpoint = "192.168.1.2:49390";
    persistent-keepalive = "25";
    allowed-ips = "0.0.0.0";
  };
  "wireguard-peer.${lush-pub}" = {
    endpoint = "192.168.5.5:51820";
    persistent-keepalive = "25";
    allowed-ips = "0.0.0.0";
  };
}
*/




################### old config #########################

/*
{ secretsDir, ... }: [
  #### local ####
  */




