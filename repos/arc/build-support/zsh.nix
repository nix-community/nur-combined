{ self, super, lib, ... }: let
  builders = {
    buildZshPlugin = { stdenvNoCC }: { pname, version, src, ... }@args: let
      pluginName = args.pluginName or pname;
      pluginFile = args.pluginFile or "${pluginName}.plugin.zsh";
      addPassthru = drv: {
        zshPlugin = {
          name = pluginName;
          file = pluginFile;
          src = drv.plugin;
        };
      };
      drvArgs = args // {
        outputs = [ "out" "plugin" ];

        inherit pluginName pluginFile;
        installPhase = args.installPhase or ''
          runHook preInstall

          if [[ ! -e $pluginName.plugin.zsh ]]; then
            echo "$pluginName.plugin.zsh does not exist" >&2
            exit 1
          fi

          pluginDir=$out/share/zsh/plugins/$pluginName
          install -D -t $pluginDir *.zsh
          if [[ -d functions ]]; then
            mv functions $pluginDir
          fi

          ln -s $pluginDir $plugin

          runHook postInstall
        '';
      };
    in lib.drvPassthru addPassthru (stdenvNoCC.mkDerivation drvArgs);
  };
in with lib; mapAttrs (_: flip self.callPackage { }) builders
