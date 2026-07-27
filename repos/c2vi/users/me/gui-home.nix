
{ config, secretsDir, pkgs, self, workDir, inputs, persistentDir, system, pkgsUnstable, ... }:

{
	imports = [
    ../common/home.nix
    ../../programs/ssh.nix

    # my gui programs
		../../programs/alacritty.nix
    # stalls the build
    #../../programs/emacs/default.nix
		../../programs/rofi/default.nix
		../../programs/zathura.nix
    ../../programs/firefox/default.nix
    ../../programs/thunderbird.nix
    inputs.lan-mouse.homeManagerModules.default

    "${inputs.vscode-server}/modules/vscode-server/home.nix"

    inputs.walker.homeManagerModules.default
	];

  programs.zed-editor = {
    enable = true;
    package = inputs.zed.packages.x86_64-linux.default;
  };

  programs.walker = {
    enable = false;
    runAsService = true;
  };


  programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
  ];

  programs.lan-mouse.systemd = true;

	gtk.cursorTheme = {
		name = "Yaru";
	 };

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      # needed for Prusa Slicer for example
      "gtk-application-prefer-dark-theme" = 1;
    };

    gtk4.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
  };

	dconf.settings = {
	  "org/virt-manager/virt-manager/connections" = {
		 autoconnect = [ "qemu:///system" "qemu+ssh://me@mac/system" ];
		 uris = [ "qemu:///system" "qemu+ssh://me@mac/system" ];
	  };
	};

  home.sessionVariables = {
    inherit system;
    VIC_BINARY = "/home/me/work/victorinix/vic";
    PPC_DATA_DIR = "/home/me/work/gitignore/ppc/data";
  };

	services.dunst.enable = true;


  home.file = {
    ".davfs2/secrets".source = config.lib.file.mkOutOfStoreSymlink "${secretsDir}/davfs2-secrets";

    #".mozilla/firefox".source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/firefox";
    ".cache/rofi-3.runcache".source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/rofi-run-cache";

    ".local/share/PrismLauncher/".source = config.lib.file.mkOutOfStoreSymlink "${workDir}/app-data/prism-launcher";
    ".local/share/DaVinciResolve/".source = config.lib.file.mkOutOfStoreSymlink "${workDir}/app-data/DaVinciResolve";
    ".local/share/JetBrains/IdeaIC2024.3".source = config.lib.file.mkOutOfStoreSymlink "${workDir}/app-data/IdeaIC2024.3";
  };


	home.packages = with pkgs; [
    btrfs-progs

    # packages that i might not need everywhere??
		#wstunnel
		rclone
		pkgsUnstable.tsx
		playerctl
		alsa-utils
		usbutils
		android-tools
    android-studio
		moonlight-qt
		pciutils
		jmtpfs
		pmutils
		cntr
		nil
    sshfs


    # gui packages
    songrec
		obsidian
    eog
		xorg.xkbcomp
		haskellPackages.xmonad-extras
		haskellPackages.xmonad-contrib
		xorg.xev
		blueman
		pavucontrol
		spotify
		networkmanagerapplet
		haskellPackages.xmobar
		kdePackages.dolphin
		mupdf
		xclip
		stalonetray
		killall
    vlc
    chromium

    # use signal from unstable, because the app itself says it would to update to be usable
		self.inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.signal-desktop
		#self.inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.ticktick
		element-desktop
		discord
		wireshark
		gparted
		xorg.xkill
    xorg.xmodmap
    inkscape
    kazam
    onlyoffice-desktopeditors

    # my own packages
    supabase-cli

		# base-devel
		gcc

		# rust
		cargo
		rust-analyzer
    rustc

		#localPacketTracer8
		#(ciscoPacketTracer8.overrideAttrs (prev: final: {
      #src = /home/me/work/software/CiscoPacketTracer_821_Ubuntu_64bit.deb;
    #}))

		#ciscoPacketTracer8

		# virtualisation
		qemu
		libvirt
		virt-manager
		freerdp
		nixd
    #(pkgs.writeShellApplication {
      #name = "log";
      #runtimeInputs = [ inputs.my-log.packages.${system}.pythonForLog ];
      #text = "cd /home/me/work/log/new; nix develop -c 'python ${workDir}/log/new/client.py'";
      #text = ''${inputs.my-log.packages.${system}.pythonForLog}/bin/python ${workDir}/log/new/client.py "$@"'';
    #})
    
    (pkgs.writeShellApplication {
      name = "rpi";
      text = let 
        myPythonRpi = pkgs.writers.writePython3Bin "myPythonRpi" { libraries = [pkgs.python3Packages.dnspython]; } ''
          # flake8: noqa
          import os
          import re
          import sys
          import subprocess

          import dns.resolver

          import socket, struct

          def get_default_gateway_linux():
            """Read the default gateway directly from /proc."""
            with open("/proc/net/route") as fh:
              for line in fh:
                fields = line.strip().split()
                if fields[1] != '00000000' or not int(fields[3], 16) & 2:
                  # If not default route or not RTF_GATEWAY, skip it
                  continue
                if fields[0] != "wlo1":
                  # only check on wlan interface
                  continue

                return socket.inet_ntoa(struct.pack("<L", int(fields[2], 16)))

          pw_map = {
            "tab": "00:0a:50:90:f1:00",
            # "phone": "86:9d:6a:bc:ca:1b", # can't do that, because phone changes mac address on reactivation of hotspot
            "lush": "dc:a6:32:cb:4d:5f",
            "hpm": "bc:17:b8:27:26:5d",
          }

          if len(sys.argv) == 1:
            with open("/etc/hosts", "r") as file:
              for line in file.readlines():
                print(line, end="")
            exit()

          if sys.argv[1] == "v":
            os.system("sudo vim /etc/hosts")
            exit()

          net = sys.argv[1]


          old = {}
          with open(f"/etc/hosts", "r") as file:
            for line in file.readlines():
              if line == "\n":
                continue
              split = line.split(" ")
              try:
                old[split[1].strip()] = split[0].strip()
              except:
                print("error with: ", split)

          #to_update = {}
          with open(f"${self}/misc/my-hosts-{net}", "r") as file:
            for line in file.readlines():
              split = line.strip().split(" ")
              try:
                if split[0][0] not in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]:
                  print("looking up: ", split[1])
                  result = dns.resolver.resolve(split[0].strip(), "A")
                  ips = list(map(lambda ip: ip.to_text(), result))
                  print("got:", ips)
                  old[split[1].strip()] = str(ips[0])
                else:
                  old[split[1].strip()] = split[0].strip()
              except Exception as e:
                print("error with: ", split)
                print(e)


          if net == "pw":
            # get phone from default route
            old["phone"] = get_default_gateway_linux()
            print("default route: phone with ip ", old["phone"])

            # search arp table
            with os.popen('arp -a') as f:
              data = f.read()
            for line in data.split("\n"):
              try:
                parts = line.split(" ")
                mac = parts[3]
                ip = parts[1][1:-1]
                for name, mac_table in pw_map.items():
                  #print("trying mac:", mac, "from arp table:", parts)
                  if mac == mac_table:
                    # found name
                    print(f"arp table: {name} with ip {ip}")
                    old[name] = ip
              except:
                print("arp table line failed:", line)
                continue

            # do arp scan
            ips = subprocess.run(["sudo", "${pkgs.arp-scan}/bin/arp-scan", "-l", "-x", "-I", "wlo1"], capture_output=True)
            for line in ips.stdout.decode("utf-8").split("\n"):
              #print("arp-scan line:", line)
              try:
                split = line.split("\t")
                ip = split[0]
                mac = split[1]
              except:
                print("error on line:", line)
                continue

              for name, mac_table in pw_map.items():
                if mac == mac_table:
                  # found name
                  print(f"arp-scan: {name} with ip {ip}")
                  old[name] = ip




          


          os.system("rm -rf /etc/hosts")
          with open("/etc/hosts", "w") as file:
            lines = []
            for key, val in old.items():
              lines.append(val + " " + key)
            file.write("\n".join(lines) + "\n")
  
          with open("/etc/current_hosts", "w") as file:
            lines = []
            for key, val in old.items():
              if val is None:
                print(f"val for {key} was None, skipping")
                continue
              lines.append(val + " " + key)
            file.write("\n".join(lines) + "\n")

        '';
      in ''sudo ${myPythonRpi}/bin/myPythonRpi "$@"'';
    })
	];
}
