{ inputs, self, ... }:
{
  flake.modules.nixos.gui =
    { lib, pkgs, ... }:
    {
      imports = [
        self.modules.nixos.xdg
        self.modules.nixos.font
        self.modules.nixos.theme
        self.modules.nixos.niri
        self.modules.nixos.nix-index
        self.modules.nixos.ime
        self.modules.nixos.pipewire
        self.modules.nixos.pam
      ];
      environment.systemPackages =
        with inputs.browser-previews.packages.${pkgs.stdenv.hostPlatform.system};
        (
          let
            chromium = pkgs.chromium.override {
              commandLineArgs = [
                "--video-capture-use-gpu-memory-buffer"
                "--force-color-profile=display-p3-d65"
                "--use-gl=angle"
                "--use-angle=vulkan"
                "--enable-zero-copy"
                "--ignore-gpu-blocklist"
                "--enable-features=${
                  lib.concatStringsSep "," [
                    "OverlayScrollbar"
                    "ParallelDownloading"
                    "MiddleClickAutoscroll"
                    "CanvasOopRasterization"
                    "AcceleratedVideoDecoder"
                    "AcceleratedVideoDecodeLinuxZeroCopyGL"
                    "AcceleratedVideoEncoder"
                    "VaapiIgnoreDriverChecks"
                    "Vulkan"
                    "VulkanFromANGLE"
                    "DefaultANGLEVulkan"
                    "UseOzonePlatform"
                  ]
                }"
                "--ozone-platform-hint=auto"
                "--ozone-platform=wayland"
                "--enable-wayland-ime"
                "--wayland-text-input-version=3"
                "--disk-cache-dir=\"$XDG_RUNTIME_DIR/chromium-cache\""
                "--oauth2-client-id=77185425430.apps.googleusercontent.com"
                "--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT"
                "--user-data-dir=\"$\{XDG_CONFIG_HOME:-$\{HOME}/.config}/chromium-sync\""
              ];
              enableWideVine = true;
            };
          in
          [
            chromium
          ]
        )
        ++ [
          (pkgs.wrapOBS {
            plugins = with pkgs.obs-studio-plugins; [
              wlrobs
              obs-backgroundremoval
              obs-pipewire-audio-capture
            ];
          })
          # pkgs.wechat
          pkgs.signal-desktop
          pkgs.porsmo
          pkgs.libnotify # foot
          pkgs.bitwarden-cli
          pkgs.gpu-screen-recorder
        ];
      programs = {
        dconf.enable = true;
        wireshark = {
          enable = true;
          package = pkgs.wireshark;
        };
        kdeconnect.enable = false;
        command-not-found.enable = false;
        gamescope.enable = true;
        # steam = {
        #   enable = true;
        #   package = pkgs.steam.override {
        #     extraPkgs = pkgs: [
        #       pkgs.maple-mono.NF-CN-unhinted
        #       pkgs.gamescope
        #       pkgs.mangohud
        #     ];
        #   };
        #   gamescopeSession.enable = true;
        #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        #   localNetworkGameTransfers.openFirewall = true;
        # };
        firefox = {
          enable = true;
          package =
            (pkgs.wrapFirefox.override { libpulseaudio = pkgs.libpressureaudio; }) pkgs.firefox-unwrapped
              { };
        };
        gnupg = {
          agent = {
            enable = false;
            pinentryPackage = pkgs.wayprompt;
            # enableSSHSupport = true;
          };
        };
      };

      virtualisation = {
        libvirtd = {
          enable = false;
          qemu.ovmf = {
            enable = true;
            packages =
              # let
              #   pkgs = import inputs.nixpkgs-22 {
              #     system = "x86_64-linux";
              #   };
              # in
              [
                pkgs.OVMFFull.fd
                pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd
              ];
          };
          qemu.swtpm.enable = true;
        };
        waydroid.enable = false;
      };

      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "adwaita";
      };
      security = {
        rtkit.enable = true;
      };
      services = {
        swayidle = {
          enable = true;
          systemdTarget = "niri.service";
          timeouts = [
            {
              timeout = 900;
              command = "/run/current-system/systemd/bin/loginctl lock-session";
            }
            {
              timeout = 915;
              command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
            }
          ];
          events = [
            {
              event = "lock";
              command = "${
                inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
              }/bin/noctalia-shell ipc call lockScreen lock";
            }
            {
              event = "before-sleep";
              command = "/run/current-system/systemd/bin/loginctl lock-session";
            }
          ];
        };
        acpid.enable = true;
        udev = {
          # Remove Yubikey Auto Lock
          # extraRules = ''
          #   ACTION=="remove",\
          #    ENV{ID_BUS}=="usb",\
          #    ENV{ID_MODEL_ID}=="0407",\
          #    ENV{ID_VENDOR_ID}=="1050",\
          #    ENV{ID_VENDOR}=="Yubico",\
          #    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
          # '';
          packages = with pkgs; [
            # qmk-udev-rules
            jlink-udev-rules
            yubikey-personalization
            nitrokey-udev-rules
            libu2f-host
            # via
            # opensk-udev-rules
            nrf-udev-rules
            disallow-generic-driver-for-switch-rules
          ];
        };
        gnome.gnome-keyring.enable = true;
        flatpak.enable = true;
        pcscd.enable = true;
        xserver = {
          enable = lib.mkDefault false;
          xkb.layout = "us";
        };
      };

    };
}
