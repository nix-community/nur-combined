{
  self,
  inputs,
  ...
}:
{
  os.kaambl.module =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports =
        with self.modules;
        (
          (with generic; [
            data
            fn
          ])
          ++ (with nixos; [
            overlay
            identity
            openssh
            fail2ban
            scrutiny
            earlyoom
            vaultix
            shared-modules
            users
            sudo
            empheral-root-full
            gui
            base
            dev
            plugIn
            garage
            vxlan-mesh
            yggdrasil
            scrutiny
            earlyoom
            dae
            secureboot
            home
            chrony
          ])
        )
        ++ [
          (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        ];

      identity.user = "elen";

      system = {
        stateVersion = "23.05";
      };
      boot = {
        lanzaboote.measuredBoot = {
          enable = true;
          pcrs = [
            0
            2
            3
            4
            7
          ];
          autoCryptenroll = {
            enable = true;
            device = config.boot.initrd.luks.devices."cryptroot".device;
          };
        };
        loader.efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/efi";
        };

        initrd = {
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "usb_storage"
            "usbhid"
            "sd_mod"
          ];
        };
        kernelModules = [
          "kvm-amd"
          "wacom"
        ];
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
        '';
        kernelPackages =
          # let
          #   helpers = pkgs.callPackage "${inputs.nix-cachyos-kernel.outPath}/helpers.nix" { };

          #   rawKernel = pkgs.cachyosKernels.linux-cachyos-bore-lto.override {
          #     pname = "linux-cachyos-custom-kernel";
          #     processorOpt = "zen4";
          #     # extraMakeFlags = [ "KCFLAGS=-march=znver5" ];
          #   };
          # in
          # helpers.kernelModuleLLVMOverride (pkgs.linuxKernel.packagesFor rawKernel);
          pkgs.linuxPackages_latest;
        blacklistedKernelModules = [ "hid_nintendo" ];
        kernelParams = [
          "amd_pstate=active"
          "amd_iommu=on"
          "random.trust_cpu=off"
          "zswap.enabled=1"
          "zswap.compressor=zstd"
          "zswap.zpool=zsmalloc"
        ];

      };
      zramSwap = {
        enable = false;
        swapDevices = 1;
        memoryPercent = 80;
        algorithm = "zstd";
      };
      systemd = {
        enableEmergencyMode = false;
        settings.Manager = {
          RebootWatchdogSec = "20s";
          RuntimeWatchdogSec = "30s";
        };
      };
      services = {
        # Did you read the comment?
        btrfs.autoScrub = {
          enable = true;
          interval = "weekly";
          fileSystems = [ "/persist" ];
        };

        blueman.enable = true;
        logind = {
          settings.Login.HandleLidSwitch = "suspend";
          settings.Login.HandlePowerKey = "poweroff"; # it sucks. laptop
          settings.Login.HandlePowerKeyLongPress = "poweroff";
        };

        metrics.enable = true;

        # wg-refresh = {
        #   enable = true;
        #   calendar = "hourly";
        # };
        syncthing = {
          enable = true;
          inherit (config.identity) user;
          openDefaultPorts = true;
        };
        sing-box.enable = true;
        snapy.instances = [
          {
            name = "persist";
            source = "/persist";
            keep = "2day";
            timerConfig.onCalendar = "*:0/5";
          }
          {
            name = "var";
            source = "/var";
            keep = "7day";
            timerConfig.onCalendar = "daily";
          }
        ];
        tailscale = {
          enable = false;
          openFirewall = true;
        };

        factorio = {
          enable = false;
          openFirewall = true;
          serverSettingsFile = config.vaultix.secrets.factorio-server.path;
          serverAdminsFile = config.vaultix.secrets.factorio-server.path;
          mods = [
            (
              (pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
                name = "helmod";
                version = "0.12.19";
                src = pkgs.fetchurl {
                  url = "https://dl-mod.factorio.com/files/89/c9e3dfbb99555ba24b085c3228a95fc7a9ad6c?secure=kuZjLfCXoc9awR6dgncRrQ,1702896059";
                  hash = "sha256-tUMZWQ8snt3y8WUruIN+skvo9M1V8ZhM7H9QNYkALYQ=";
                };
                dontUnpack = true;
                installPhase = ''
                  runHook preInstall
                  install -m 0644 $src -D $out/helmod_${finalAttrs.version}.zip
                  runHook postInstall
                '';
              }))
              // {
                deps = [ ];
              }
            )
          ];
        };

        gvfs.enable = false;
        xserver.videoDrivers = [ "amdgpu" ];
      };
      hardware = {
        acpilight.enable = true;
        bluetooth = {
          enable = true; # enables support for Bluetooth
          powerOnBoot = true; # powers up the default Bluetooth controller on boot
          settings = {
            General = {
              Enable = "Source,Sink,Media,Socket";
            };
          };
        };
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
      networking.wireless.iwd.enable = true;

      systemd.tmpfiles.rules = [
        # "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
        "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
          <monitors version="2">
              <configuration>
                  <logicalmonitor>
                      <x>0</x>
                      <y>0</y>
                      <scale>2</scale>
                      <primary>yes</primary>
                      <monitor>
                          <monitorspec>
                              <connector>eDP-1</connector>
                              <vendor>BOE</vendor>
                              <product>0x0893</product>
                              <serial>0x00000000</serial>
                          </monitorspec>
                          <mode>
                              <width>2160</width>
                              <height>1440</height>
                              <rate>60.001</rate>
                          </mode>
                      </monitor>
                  </logicalmonitor>
              </configuration>
          </monitors>
        ''}"
      ];

      nixpkgs = {
        hostPlatform = "x86_64-linux";
        overlays = [
          self.overlays.default
        ];
        config = {
          allowUnsupportedSystem = true;
          allowUnfree = true;
          permittedInsecurePackages = [
            "olm-3.2.16"
          ];
        };
      };
    };
}
