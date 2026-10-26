{
  flake.modules.nixos.chrony =
    { config, ... }:
    {
      networking.timeServers =
        if config.data.node.${config.networking.hostName}.censor then
          [
            "ntp1.aliyun.com"
            "240e:982:13a3:f700:70c6:e4fd:a208:19d3"
            "edu.ntp.org.cn"
            "2001:250:380a:5::10"
          ]
        else
          [
            "162.159.200.1"
            "162.159.200.123"
            "2606:4700:f1::1"
            "2606:4700:f1::123"
            "ntp.nict.jp"
          ];

      services.chrony = {
        enable = true;
        extraConfig = ''
          makestep 1.0 3
        '';
      };
    };
}
