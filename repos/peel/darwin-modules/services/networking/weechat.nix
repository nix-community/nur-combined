{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.weechat;
  
  validPaths = paths: with builtins;
    let check = paths: foldl' (x: y: x && (pathExists y)) true paths;
    in check paths || trace "weechat-config: defined extra config files missing. Configuration will not be applied." false;


  runWithOpenSSL = file: cmd: pkgs.runCommand file {
    buildInputs = [ pkgs.openssl ];
  } cmd;
  key = runWithOpenSSL "relay.key" "openssl genrsa -out $out 2048";
  cert = runWithOpenSSL "relay.cert" ''
    openssl req \
      -x509 -new -nodes -key ${key} \
      -days 10000 -out $out -subj "/CN=localhost"
  '';
  bundle = pkgs.writeTextFile{
    name = "relay.pem";
    text = ''
      ${builtins.readFile key}
      ${builtins.readFile cert}
    '';
  };

  relayCfg = pkgs.writeTextFile {
    name = "relay.cfg";
    text = ''
      /relay sslcertkey
      /relay add weechat 9001
    '';
  };
  
  weechatConfigure = paths: pkgs.writeScript "weechat-configure" ''
    server_status(){
      launchctl list | grep weechat | head -1 | awk '{ print $2 }'
    }

    write_config(){
      for f in ${strings.escapeShellArgs paths}; do
        sed 's/^/*/' ''${f} > ''${1}/weechat_fifo
      done
    }

    setup_ssl(){
      mkdir -p ''${1}/ssl
      ln -fvs ${bundle} ''${1}/ssl/relay.pem
    }

    for i in {1..24}; do 
      server_status == 0 \
      && echo "Writing config..." \
      && setup_ssl ''${1} \
      && write_config ''${1} \
      && break \
      || echo "Weechat service not running..." \
      && sleep 5;
    done
  '';
  
  weechat = withSlack : withMatrix: pkgs.weechat.override {
    configure = {availablePlugins,...}: {
      extraBuildInputs = [ pkgs.luaPackages.cjson ];
      plugins =
        with availablePlugins; []
        ++ lib.optionals withSlack [
          (python.withPackages (ps: with ps; [websocket_client xmpppy]))
        ]
        ++ lib.optionals withMatrix [
          lua
        ];
      scripts = []
        ++ lib.optionals withMatrix [ pkgs.weechatScripts.weechat-matrix-bridge ]
        ++ lib.optionals withSlack [ pkgs.weechatScripts.wee-slack ];
    };
  };
in
{
  options = {
    services.weechat = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable weechat relay service.
        '';
      };
      home = mkOption {
        default = "/var/weechat";
        description = ''
          Where weechat configuration is stored.
        '';
      };
      withSlack = mkOption {
        default = false;
        description = ''
          Whether to enable wee-slack plugin.
        '';
      };
      withMatrix = mkOption {
        default = false;
        description = ''
          Whether to enable weechat matrix plugin.
        '';
      };
      extraConfigFiles = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          Paths to file containing commands to be executed upon startup. Executed in provided order.
        '';
      };
      scripts = mkOption {
        default = [];
        example = literalExample "[ pkgs.weechat.wee-slack ]";
        description = ''
          Additional scripts or plugins to be installed.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents.weechat-config = {
      path = [ pkgs.coreutils pkgs.gawk pkgs.gnugrep ];
      command = "${weechatConfigure ([ relayCfg ] ++ cfg.extraConfigFiles) } ${cfg.home}";
      serviceConfig.ProcessType = "Background";
      serviceConfig.KeepAlive.OtherJobEnabled."org.nixos.weechat" = true;
    };

    launchd.user.agents.weechat = {
      path = [
        (weechat cfg.withSlack cfg.withMatrix)
      ];
      environment = {
        LANG = "en_US.utf8";
        LC_ALL = "en_US.utf8";
        WEECHAT_EXTRA_LIBDIR = "${weechat cfg.withSlack cfg.withMatrix}/share";
      } // optionalAttrs (cfg.withMatrix) {
        LUA_CPATH = "${pkgs.luaPackages.getLuaCPath pkgs.luaPackages.cjson}";
        LUA_PATH = "${pkgs.luaPackages.getLuaPath pkgs.luaPackages.cjson}";
      };
      command = "${weechat cfg.withSlack cfg.withMatrix}/bin/weechat-headless --dir ${cfg.home}";
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
    };
  };
}
