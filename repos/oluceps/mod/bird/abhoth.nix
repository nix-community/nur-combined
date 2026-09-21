{ self, inputs, ... }:
{
  flake.modules.nixos."bird/abhoth" =
    { config, ... }:
    {
      imports = [
        self.modules.nixos.bird
        inputs.autopeer.nixosModules.default
      ];
      services.autopeer = {
        enable = true;
        localAsn = 4242420291;
        port = 9341;
        birdConfDir = "/var/lib/autopeer";
        environmentFile = config.vaultix.secrets."autopeer".path;
      };
      vaultix.secrets = {
        autopeer = {
          insert = {
            "62dcce68ed5b883e4afe9feceb2e0945067a3f3b2c708361d9b6c18704d4ff10".content = "dn42abhoth";
            "aeb537ee3881de1a3f4ffe192421fb3ae4b03dd025cd2bf5fc640222f43df0a9".content =
              "jp-tyo-1.dn42.nyaw.xyz"; # abhoth
          };
        };
        babel-auth = {
          owner = "bird";
        };
      };

      systemd.network = {
        netdevs."10-dn42-dummy-0" = {
          enable = true;
          netdevConfig = {
            Kind = "dummy";
            Name = "dn42-dummy";
          };
        };
        networks."10-dn42-dummy-0" = {
          enable = true;
          DHCP = "no";
          matchConfig.Name = "dn42-dummy";
          address = [ "fdda:1965:1d5f::${toString ((config.fn.getThisNode).id + 1)}" ];
        };
      };
      bird = {
        config = ''
          include "${config.vaultix.secrets.babel-auth.path}";

          ipv6 table dn42_v6;

          roa4 table dn42_roa4;
          roa6 table dn42_roa6;

          define DN42_V6_RANGE = [ fd00::/8+ ];

          # main rtr server
          protocol rpki roa_dn42_1 {
              roa4 { table dn42_roa4; };
              roa6 { table dn42_roa6; };
              remote "rpki.akae.re" port 8082;
              
              refresh 600;
              retry 300;
              expire 7200;
          }

          protocol rpki roa_dn42_2 {
            roa4 { table dn42_roa4; };
            roa6 { table dn42_roa6; };
            remote "rpki.dn42.launchpadx.top" port 8082;

            retry keep 90;
            refresh keep 900;
            expire keep 3600;
          }

          function dn42_roa_check() {
              if net.type = NET_IP4 then {
                  # bgp_path.last is origin ASN
                  if roa_check(dn42_roa4, net, bgp_path.last) = ROA_VALID then return true;
                  return false;
              }
              
              if net.type = NET_IP6 then {
                  if roa_check(dn42_roa6, net, bgp_path.last) = ROA_VALID then return true;
                  return false;
              }
              
              return false;
          }
          protocol direct direct_dn42 {
            ipv6 { table dn42_v6; };
            interface "dn42-dummy";
          }          

          function dn42_import_from_peer(int peer_asn; int peer_id) -> bool {

            if net.type != NET_IP6 then return false;

            if (net.len < 44) || (net.len > 64) then return false;
            
            if net ~ DN42_FIELD then return false;
            
            if net ~ DN42_V6_RANGE && dn42_roa_check() then return true;

            return false;
          }

          function dn42_export_to_peer(int peer_asn; int peer_id) -> bool {
            # announce my field
            if source = RTS_DEVICE && net ~ DN42_FIELD then return true;
            
            # my A -> me -> my B
            if source = RTS_BGP then return true;
            
            return false;
          }

          # pipe to main table
          protocol pipe pipe_dn42 {
            table master6;
            peer table dn42_v6;
            
            import filter {
              if net ~ DN42_V6_RANGE then accept;
              reject;
            };
            
            # 从 master6 侧不向 dn42_v6 输出任何东西
            # (因为在 static_dn42 里已经独立生成了宣告前缀)
            export none; 
          }

          include "/var/lib/autopeer/*.conf";
        '';
      };
    };
}
