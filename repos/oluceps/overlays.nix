{ inputs', inputs }:
[
  (
    final: prev:
    prev.lib.genAttrs [
      "ragenix"
      "prismlauncher"
      "resign"
      "nix-direnv"
      "radicle"
      "nixd"
    ] (n: inputs'.${n}.packages.default)
    # //
    # GUI applications overlay. for stability
    # prev.lib.genAttrs [ "hyprland" ] (n: (import inputs.nixpkgs-gui { inherit system; }).${n})

    // {
      # inherit
      #   (import inputs.nixpkgs-factorio {
      #     inherit (prev) system;
      #     config.allowUnfree = true;
      #   })
      #   factorio-headless-experimental
      #   ;
      inherit
        (import inputs.nixpkgs-factorio {
          inherit (prev) system;
        })
        ccid
        ;

      inherit (inputs'.browser-previews.packages) google-chrome-beta;

      helix = inputs'.helix.packages.default.override {
        includeGrammarIf =
          grammar:
          prev.lib.any (name: grammar.name == name) [
            "toml"
            "rust"
            "nix"
            "lua"
            "make"
            "protobuf"
            "yaml"
            "json"
            "markdown"
            "html"
            "css"
            "tsx"
            "jsx"
            "zig"
            "c"
            "cpp"
            "go"
            "python"
            "bash"
            "kotlin"
            "fish"
            "javascript"
            "typescript"
            "sway"
            "diff"
            "comment"
            "vue"
            "nu"
            "typst"
            "scheme"
            "just"
          ];
      };

      # sha256 = "0000000000000000000000000000000000000000000000000000";

      scx = inputs'.nyx.packages.scx;

      picom = prev.picom.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "yshui";
          repo = "picom";
          rev = "0fe4e0a1d4e2c77efac632b15f9a911e47fbadf3";
          sha256 = "sha256-daLb7ebMVeL+f8WydH4DONkUA+0D6d+v+pohJb2qjOo=";
        };
      });
      phantomsocks =
        with prev;
        buildGoModule rec {
          pname = "phantomsocks";
          version = "unstable-2023-11-30";

          src = fetchFromGitHub {
            owner = "macronut";
            repo = pname;
            rev = "b1b13c5b88cf3bac54f39c37c0ffcb0b46e31049";
            hash = "sha256-ptCzd2/8dNHjAkhwA2xpZH8Ki/9DnblHI2gAIpgM+8E=";
          };

          vendorHash = "sha256-0MJlz7HAhRThn8O42yhvU3p5HgTG8AkPM0ksSjWYAC4=";

          ldflags = [
            "-s"
            "-w"
          ];
          buildInputs = [ libpcap ];
          tags = [ "pcap" ];
        };

      dae-unstable = prev.buildGoModule rec {
        pname = "dae";
        version = "unstable";

        src = prev.fetchFromGitHub {
          owner = "daeuniverse";
          repo = "dae";
          rev = "16dfabc93596d4036c0c8418789a7b114bf61619";
          hash = "sha256-Ya/M0/bx8O50kqdHO14mPz56FfW4xXDu7rYLjlB3OZc=";
          fetchSubmodules = true;
        };

        vendorHash = "sha256-/r118MbfHxXHt7sKN8DOGj+SmBqSZ+ttjYywnqOIPuY=";

        proxyVendor = true;

        nativeBuildInputs = [ prev.clang ];

        ldflags = [
          "-s"
          "-w"
          "-X github.com/daeuniverse/dae/cmd.Version=${version}"
          "-X github.com/daeuniverse/dae/common/consts.MaxMatchSetLen_=64"
        ];

        preBuild = ''
          make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
          NOSTRIP=y \
          ebpf
        '';

        # network required
        doCheck = false;

        postInstall = ''
          install -Dm444 install/dae.service $out/lib/systemd/system/dae.service
          substituteInPlace $out/lib/systemd/system/dae.service \
            --replace /usr/bin/dae $out/bin/dae
        '';
        meta.mainProgram = "dae";
      };

      record-status = prev.writeShellScriptBin "record-status" ''
        pid=`pgrep wf-recorder`
        status=$?
        if [ $status != 0 ]
        then
          echo '';
        else
          echo '';
        fi;
      '';

      screen-recorder-toggle = prev.writeShellScriptBin "screen-recorder-toggle" ''
        pid=`${prev.procps}/bin/pgrep wl-screenrec`
        status=$?
        if [ $status != 0 ]
        then
          ${prev.wl-screenrec}/bin/wl-screenrec -g "$(${prev.slurp}/bin/slurp)" -f $HOME/Videos/record/$(date +'recording_%Y-%m-%d-%H%M%S.mp4');
        else
          ${prev.procps}/bin/pkill --signal SIGINT wl-screenrec
        fi;
      '';

      save-clipboard-to = prev.writeShellScriptBin "save-clipboard-to" ''
        wl-paste > $HOME/Pictures/Screenshots/$(date +'shot_%Y-%m-%d-%H%M%S.png')
      '';
      switch-mute = final.nuenv.writeScriptBin {
        name = "switch-mute";
        script =
          let
            pamixer = prev.lib.getExe prev.pamixer;
          in
          ''
            ${pamixer} --get-mute | str trim | if $in == "false" { ${pamixer} -m } else { ${pamixer} -u }
          '';
      };

      clean-home = final.nuenv.writeScriptBin {
        name = "clean-home";
        script = ''
          cd /home/riro/
          ls | each {|i| findmnt $i.name | if $in == "" { rm -rf $i.name}}
          cd -
        '';
      };
      systemd-run-app = prev.writeShellApplication {
        name = "systemd-run-app";
        text = ''
          name=$(${final.uutils-coreutils-noprefix}/bin/basename "$1")
          id=$(${final.openssl}/bin/openssl rand -hex 4)
          exec systemd-run \
            --user \
            --scope \
            --unit "$name-$id" \
            --slice=app \
            --same-dir \
            --collect \
            --property PartOf=graphical-session.target \
            --property After=graphical-session.target \
            -- "$@"
        '';
      };
    }
  )
]
