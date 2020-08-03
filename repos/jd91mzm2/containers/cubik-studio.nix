nixpkgs: system:

nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [({ pkgs, ... }: {
    boot.isContainer = true;

    environment.systemPackages =
      let
        source = pkgs.fetchurl {
          # ipfs = "QmQ1L61oxzMDeGw8CMccFSHVCqUsk1gzhHzh6M4w4nh788";
          url = "https://ipfs.io/ipfs/QmQ1L61oxzMDeGw8CMccFSHVCqUsk1gzhHzh6M4w4nh788";
          sha256 = "WBrDM/VI4OEDBzyf7WSEFZuju3HQvhLcx9PvzJpYFuQ=";
        };
        unzipped = pkgs.runCommand "cubik-studio-download" {} ''
          mkdir $out
          cd $out
          ${pkgs.unzip}/bin/unzip "${source}"
        '';
        cubik-studio = pkgs.runCommand "cubik-studio" {} ''
          mkdir -p $out/bin
          mkdir -p $out/share

          cp "${unzipped}/cubikupdater.x86_64" "$out/bin/.cubikupdater-inner"
          chmod +x "$out/bin/.cubikupdater-inner"

          patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" "$out/bin/.cubikupdater-inner"

          cat > "$out/bin/cubikupdater" <<EOF
          #!${pkgs.stdenv.shell} -e
          [ -e cubikupdater_Data ] || cp -r "$out/share/cubikupdater_Data" .
          "$out/bin/.cubikupdater-inner"
          EOF
          chmod +x "$out/bin/cubikupdater"

          cp -r ${unzipped}/cubikupdater_Data "$out/share/cubikupdater_Data"
        '';
      in [
        cubik-studio

        pkgs.libGL
        pkgs.xorg.libX11
        pkgs.xorg.libXcursor
        pkgs.xorg.libXrandr
        pkgs.binutils
      ];

    users = {
      mutableUsers = false;
      users = {
        root.hashedPassword = "!!!";
        user = {
          isNormalUser = true;
          hashedPassword = "";
        };
      };
    };
  })];
}

  # { buildFHSUserEnv }:

  # buildFHSUserEnv {
  #   name = "cubik-studio";
  #   targetPkgs = pkgs: let
  #     source = pkgs.fetchurl {
  #       # ipfs = "QmQ1L61oxzMDeGw8CMccFSHVCqUsk1gzhHzh6M4w4nh788";
  #       url = "https://ipfs.io/ipfs/QmQ1L61oxzMDeGw8CMccFSHVCqUsk1gzhHzh6M4w4nh788";
  #       sha256 = "WBrDM/VI4OEDBzyf7WSEFZuju3HQvhLcx9PvzJpYFuQ=";
  #     };
  #     unzipped = pkgs.runCommand "cubik-studio-download" {} ''
  #       mkdir $out
  #       cd $out
  #       ${pkgs.unzip}/bin/unzip "${source}"
  #     '';
  #     cubik-studio = pkgs.runCommand "cubik-studio" {} ''
  #       mkdir -p $out/bin
  #       mkdir -p $out/share

  #       cp "${unzipped}/cubikupdater.x86_64" "$out/bin/cubikupdater"
  #       chmod +x "$out/bin/cubikupdater"

  #       cp -r ${unzipped}/cubikupdater_Data "$out/bin/cubikupdater_Data"
  #     '';
  #   in with pkgs; [
  #     cubik-studio

  #     libGL
  #     xorg.libX11
  #     xorg.libXcursor
  #     xorg.libXrandr
  #     strace
  #   ];
  # }
