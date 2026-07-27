{ pkgs, dataDir, config, inputs, system, lib, secretsDir, ... }:

 /*

## ports
- 49001 ssh me-hosting
- 49002 ssh ppc-hosting
- 49003 ssh pcmc
- 49004 ssh fe

- 49101 mc first
- 49102 mc first voice
- 49103 mc nonstop
- 49104 mc nonstop voice
- 49105 mc lage0
- 49106 mc lage0 voice
- 49107 mc lobby
- 49108 mc lobby voice
- 49109 mc compass
- 49110 mc compass voice
- 49111 mc second
- 49112 mc second voice
- 49113 mc second bedrock
- 49114 mc lobby bedrock

- me hosting ports
	- 8000 wiki site
	- 8001 lage0 site
	- 8002 plausible site
	- 8003 ppc-site
	- 8004 instant db
	- 8005 instant webui

- ppc hosting ports
  - 8000 dav
  - 8001 affine

## hosting container ips (on the interface br-proxy
  - fusu 192.168.101.1
  - me-hosting 192.168.101.2
  - ppc-hosting 192.168.101.3
  - pcmc 192.168.101.4

 */

 let
  /**
    thanks: @melektron
    This builder creates a small shell script that wraps arion to specify
    it to operate on a specific registered arion service identified by `srv_name`.
    This can be used to manage the docker-compose functionality of an arion service
    that is defined in the NixOS system, independently from the systemctl service that 
    starts it. If you start/stop compose projects using this, you should first stop 
    the systemctl service. 
   */
  createArionServiceManager = srv_name: setup: (
    pkgs.writeShellScriptBin "manage-arion-${srv_name}" ''
      echo operating on: ${config.virtualisation.arion.projects."${srv_name}".settings.out.dockerComposeYaml}
      ${setup}
      ${pkgs.lib.getExe inputs.arion.packages."${system}".arion} --prebuilt-file ${config.virtualisation.arion.projects."${srv_name}".settings.out.dockerComposeYaml} $@
    ''
  );

  basicTraefikSettingAttrs = configs: extraRouters: extraServices: let
    tmp = map (val: basicTraefikSetting val) configs;
    routerList = map (val: val.routers) tmp;
    serviceList = map (val: val.services) tmp;
    routers = lib.attrsets.mergeAttrsList (routerList ++ extraRouters);
    services = lib.attrsets.mergeAttrsList (serviceList ++ extraServices);
  in { inherit routers services; };

  basicTraefikSetting = { name, domain, host, port }: let
    host_ip = 
      if host == "me-hosting" then "192.168.1.20"
      else if host == "pcmc" then "192.168.1.23"
      else if host == "ppc-hosting" then "192.168.1.21"
      else if host == "fesu" then "192.168.1.4"
      else host;

  in {
    
    impotrs = [
      "${inputs.hetzner_ddns}/release/nixos_module.nix"
    ];
    
    routers.${name} = {
      rule = "Host(`${domain}`)";
      service = name;
      tls = {
        certResolver = "LE";
        domains = [
          { main = domain; }
        ];
      };
    };

    services.${name}.loadBalancer.servers = [
      { url = "http://${host_ip}:${builtins.toString port}"; }
    ];

  };



in {
  imports = [
    "${inputs.hetzner_ddns}/release/NixOS/nixos_module.nix"
  ];
  
  environment.systemPackages = [
    pkgs.arion

    # Do install the docker CLI to talk to podman.
    # Not needed when virtualisation.docker.enable = true;
    pkgs.docker-client

    # add all the service managers
  ];

  ############################ virtualisation #########################
  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.libvirtd.enable = true;


  virtualisation.arion = {
    backend = "podman-socket";
  };
  
  users.extraUsers.me.extraGroups = ["podman"];

  # incus
  virtualisation.incus.enable = true;
  users.users.me.extraGroups = [ 
    "incus-admin"
  ];
  networking.nftables.enable = true;
  
  
  
  
  ############################ networking #########################
  boot.kernel.sysctl = { 
    "net.ipv4.ip_forward" = true;
  };
  
  
  
  
  ############################ dyndns #########################
  systemd.services.hetzner_ddns.serviceConfig = {
    User = "me";
    Group = "users";
  };
  services.hetzner_ddns = {
    protections = false;
    enable = true;
    api_key_file = "/home/me/secrets/hetzner_ddns_key";
    zones = [
      {
        domain = "c2vi.dev";
        records = [
          {
            name = "home";
            type = "A";
          }
        ];
      }
      {
        domain = "ppc.social";
        records = [
          {
            name = "@";
            type = "A";
          }
        ];
      }
    ];
  };
  
  
  
  ############################ containers #########################

  # me-hosting container
  containers.me-hosting = {
    autoStart = true;
    privateNetwork = true;
    privateUsers = "pick";
    #hostAddress = "192.168.100.10";
    hostBridge = "br0";
    #localAddress = "192.168.100.11";
    localAddress = "192.168.1.20/24";
    extraFlags = [ "--system-call-filter=@keyring" ];
    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/net/tun";
      }
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];
    bindMounts."data-dir" = {
      mountPoint = "/root/host:idmap";
      hostPath = "${dataDir}/me-hosting";
      isReadOnly = false;
    };

    # see: https://github.com/systemd/systemd/issues/27994
    bindMounts."/run/sys" = {
      hostPath = "/sys";
      isReadOnly = false;
    };

    forwardPorts = [
      {
        hostPort = 49001;
        containerPort = 22;
        protocol = "tcp";
      }
    ];
    config = { config, pkgs, lib, ... }: {
      imports = [
        ./fesu-hosting-base.nix
      ];
    };
  };

  # ppc-hosting container
  containers.ppc-hosting = {
    autoStart = true;
    privateNetwork = true;
    privateUsers = "pick";
    #hostAddress = "192.168.100.12";
    hostBridge = "br0";
    #localAddress = "192.168.100.13";
    localAddress = "192.168.1.21/24";
    extraFlags = [ "--system-call-filter=@keyring" ];
    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/net/tun";
      }
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];
    bindMounts."data-dir" = {
      mountPoint = "/root/host:idmap";
      hostPath = "${dataDir}/ppc-hosting";
      isReadOnly = false;
    };

    # see: https://github.com/systemd/systemd/issues/27994
    bindMounts."/run/sys" = {
      hostPath = "/sys";
      isReadOnly = false;
    };

    forwardPorts = [
      {
        hostPort = 49002;
        containerPort = 22;
        protocol = "tcp";
      }
    ];
    config = { config, pkgs, lib, ... }: {
      imports = [
        ./fesu-hosting-base.nix
      ];
      users.users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuH2ilZeIQrr9wYtBtQyRD5oaVkuLImjm9EIGfn+wqw" # Mr3DAlien
        ];
      };

    };
  };

  # pcmc container
  containers.pcmc = {
    autoStart = true;
    privateNetwork = true;
    privateUsers = "pick";
    #hostAddress = "192.168.100.14";
    hostBridge = "br0";
    #localAddress = "192.168.100.15";
    localAddress = "192.168.1.23/24";
    extraFlags = [ "--system-call-filter=@keyring" ];
    allowedDevices = [
      {
        modifier = "rwm";
        node = "/dev/net/tun";
      }
      {
        modifier = "rwm";
        node = "/dev/fuse";
      }
    ];
    bindMounts."data-dir" = {
      mountPoint = "/root/host:idmap";
      hostPath = "${dataDir}/pcmc";
      isReadOnly = false;
    };

    # see: https://github.com/systemd/systemd/issues/27994
    bindMounts."/run/sys" = {
      hostPath = "/sys";
      isReadOnly = false;
    };

    forwardPorts = [
      { # ssh port
        hostPort = 49003;
        containerPort = 22;
        protocol = "tcp";
      }
    ]
    ++ # add all mc server ports as tcp
      (map (port: {
        hostPort = port;
        containerPort = port;
        protocol = "tcp";
      }) (lib.range 49100 49200))
    ++ # add all mc server ports as udp
      (map (port: {
        hostPort = port;
        containerPort = port;
        protocol = "udp";
      }) (lib.range 49100 49200))
    ;

    config = { config, pkgs, lib, ... }: {
      imports = [
        ./fesu-hosting-base.nix
      ];
    };
  };


  



  ############################ compass app #########################
  systemd.services.compass = {
    enable = true;
    description = "Compass Bot Deployment";
    unitConfig = {
      Type = "simple";
    };
    serviceConfig = {
      User = "server";
      Group = "server";
      Restart = "always";
      RestartSec = "500s";
      ExecStart = "${lib.getExe inputs.compass.packages.${system}.default} --data ${dataDir}/compass --config ${dataDir}/compass/config.json --db ${dataDir}/compass/compass.db --settings ${dataDir}/compass/settings.json";
    };
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
  };

  
  
  
  ############################ traefik #########################
  services.traefik = {
    enable = true;
    #dataDir = "${dataDir}/traefik";

    staticConfigOptions = {

      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "LE";
        };
      };

      log = {
        level = "TRACE";
        #filePath = "${config.services.traefik.dataDir}/traefik.log";
        #format = "json";
      };

      certificatesResolvers.LE.acme = {
        email = "c2vi.dev@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
      api.insecure = true;
    };

    dynamicConfigOptions = {
      http = (basicTraefikSettingAttrs 
        # basic configs
        [ 
          { name = "wiki-site"; domain = "wiki.ppc.social"; host = "me-hosting"; port = 8000; }
          { name = "lage0-site"; domain = "lage0.c2vi.dev"; host = "me-hosting"; port = 8001; }
          { name = "plausible"; domain = "plausible.c2vi.dev"; host = "me-hosting"; port = 8002; }
          { name = "ppc-site"; domain = "ppc.social"; host = "me-hosting"; port = 8003; }
          { name = "compass-site"; domain = "compass.ppc.social"; host = "fesu"; port = 3000; }
          { name = "dav"; domain = "dav.ppc.social"; host = "ppc-hosting"; port = 8000; }
          { name = "instant"; domain = "instant.ppc.social"; host = "me-hosting"; port = 8004; }
          { name = "instant-backend"; domain = "instant-backend.ppc.social"; host = "me-hosting"; port = 8005; }
          { name = "isotoke-website"; domain = "isotoke.ppc.social"; host = "192.168.1.26"; port = 80; }
          { name = "affine"; domain = "affine.ppc.social"; host = "ppc-hosting"; port = 8001; }
        ]

        # extraRouters (full configs)
        [
        ]

        # extraServices (full configs)
        [
        ]);

    };
  };


}
