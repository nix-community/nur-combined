{ pkgs, ... }:
{
  enable = true;
  settings = {
    interfaces = [
      {
        device = "wlan0";
        dns = "tcp://208.67.220.220:5353";
        hint = "w-md5,s-seg,https";
        name = "default";
      }
      {
        device = "wlan0";
        dns = "tcp://208.67.220.220:443";
        hint = "ipv6,w-seq,w-md5";
        name = "v6";
      }
      {
        device = "wlan0";
        dns = "tcp://208.67.220.220:443";
        hint = "df";
        name = "df";
      }
      {
        device = "wlan0";
        dns = "tcp://208.67.220.220:5353";
        hint = "http,ttl";
        name = "http";
        ttl = 15;
      }
    ];
    profiles = [
      (pkgs.writeText "default.conf" ''
        [default]
        google.com=108.177.111.90,108.177.126.90,108.177.127.90,108.177.97.100,142.250.1.90,142.250.112.90,142.250.13.90,142.250.142.90,142.250.145.90,142.250.148.90,142.250.149.90,142.250.152.90,142.250.153.90,142.250.158.90,142.250.176.64,142.250.176.95,142.250.178.160,142.250.178.186,142.250.180.167,142.250.193.216,142.250.27.90,142.251.0.90,142.251.1.90,142.251.111.90,142.251.112.90,142.251.117.90,142.251.12.90,142.251.120.90,142.251.160.90,142.251.161.90,142.251.162.90,142.251.166.90,142.251.167.90,142.251.169.90,142.251.170.90,142.251.18.90,172.217.218.90,172.253.117.90,172.253.63.90,192.178.49.10,192.178.49.174,192.178.49.178,192.178.49.213,192.178.49.24,192.178.50.32,192.178.50.43,192.178.50.64,192.178.50.85,216.239.32.40,64.233.189.191,74.125.137.90,74.125.196.113,142.251.42.228
        ajax.googleapis.com=[google.com]
        .google.com=[google.com]
        .google.com.hk=[google.com]
        .googleusercontent.com=[google.com]
        .ytimg.com=[google.com]
        .youtube.com=[google.com]
        youtube.com=[google.com]
        .youtube-nocookie.com=[google.com]
        youtu.be=[google.com]
        .ggpht.com=[google.com]
        .gstatic.com=[google.com]
        .translate.goog=[google.com]
        blogspot.com=[google.com]
        .blogspot.com=[google.com]
        blogger.com=[google.com]
        .blogger.com=[google.com]
        fonts.googleapis.com=120.253.250.225
        .googleapis.com=[google.com]
        .googleusercontent.com=[google.com]

        [df]
        .mega.nz
        .mega.co.nz
        .mega.io
        mega.nz
        mega.co.nz
        mega.io

        # [v6]
        # .googlevideo.com

        [http]
        ocsp.int-x3.letsencrypt.org
        captive.apple.com
        neverssl.com
        www.msftconnecttest.com
      '')
    ];
    services = [
      {
        address = "127.0.0.1:1681";
        name = "socks";
        protocol = "socks";
      }
    ];
  };
}
