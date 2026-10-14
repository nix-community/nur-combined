{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalAttrs
    types
    ;
  cfg = config.programs.rea;
  free = cfg.freeTools;
  runtimeTools = pkgs.callPackage ../../pkgs/rea-agents/runtime-tools.nix { };
  bareRea = pkgs.callPackage ../../pkgs/rea-agents {
    withGhidra = false;
    withFullTools = false;
  };

  usesJdk = cfg.ghidra.enable || free.jadx.enable;
  usesPrlimit =
    free.prlimit.enable || free.binwalk.enable || free.unblob.enable || free.wakaru.enable;

  freeToolPackages =
    optional free.chromium.enable pkgs.chromium
    ++ optional free.androidTools.enable pkgs.android-tools
    ++ optional free.apktool.enable pkgs.apktool
    ++ optional free.ilspycmd.enable pkgs.ilspycmd
    ++ optional free.binwalk.enable pkgs.binwalk
    ++ optional free.unblob.enable runtimeTools.unblobRuntime
    ++ optional free.mitmproxy.enable pkgs.mitmproxy
    ++ optional free.wakaru.enable runtimeTools.wakaru
    ++ optional free.pwntools.enable runtimeTools.pwntoolsPython
    ++ optional free.pwndbg.enable runtimeTools.pwndbg
    ++ optional usesPrlimit pkgs.util-linux
    ++ optional usesJdk pkgs.jdk21;

  freeToolEnvironment =
    optionalAttrs free.chromium.enable {
      REA_BROWSER_EXECUTABLE = runtimeTools.environment.REA_BROWSER_EXECUTABLE;
    }
    // optionalAttrs free.androidTools.enable {
      REA_ADB_PATH = runtimeTools.environment.REA_ADB_PATH;
    }
    // optionalAttrs free.apktool.enable {
      REA_APKTOOL_COMMAND = runtimeTools.environment.REA_APKTOOL_COMMAND;
    }
    // optionalAttrs free.jadx.enable {
      REA_JADX_MCP_JAR = "${runtimeTools.environment.REA_JADX_MCP_JAR}";
    }
    // optionalAttrs free.ilspycmd.enable {
      REA_ILSPY_CMD_PATH = runtimeTools.environment.REA_ILSPY_CMD_PATH;
    }
    // optionalAttrs free.binwalk.enable {
      REA_BINWALK_COMMAND = runtimeTools.environment.REA_BINWALK_COMMAND;
      REA_FIRMWARE_PRLIMIT_COMMAND = runtimeTools.environment.REA_FIRMWARE_PRLIMIT_COMMAND;
    }
    // optionalAttrs free.unblob.enable {
      REA_UNBLOB_COMMAND = runtimeTools.environment.REA_UNBLOB_COMMAND;
      REA_FIRMWARE_PRLIMIT_COMMAND = runtimeTools.environment.REA_FIRMWARE_PRLIMIT_COMMAND;
    }
    // optionalAttrs free.mitmproxy.enable {
      REA_MITMDUMP_COMMAND = runtimeTools.environment.REA_MITMDUMP_COMMAND;
    }
    // optionalAttrs free.wakaru.enable {
      REA_WAKARU_COMMAND = runtimeTools.environment.REA_WAKARU_COMMAND;
      REA_JAVASCRIPT_PRLIMIT_COMMAND = runtimeTools.environment.REA_JAVASCRIPT_PRLIMIT_COMMAND;
    }
    // optionalAttrs (free.pwntools.enable || free.pwndbg.enable) {
      REA_PWNTOOLS_PYTHON = runtimeTools.environment.REA_PWNTOOLS_PYTHON;
    }
    // optionalAttrs free.pwndbg.enable {
      REA_PWNDBG_GDB = runtimeTools.environment.REA_PWNDBG_GDB;
      REA_PWNDBG_GDBINIT = runtimeTools.environment.REA_PWNDBG_GDBINIT;
      REA_PWNDBG_VENV_PATH = runtimeTools.environment.REA_PWNDBG_VENV_PATH;
      PWNDBG_NO_AUTOUPDATE = runtimeTools.environment.PWNDBG_NO_AUTOUPDATE;
    }
    // optionalAttrs free.prlimit.enable {
      REA_FIRMWARE_PRLIMIT_COMMAND = runtimeTools.environment.REA_FIRMWARE_PRLIMIT_COMMAND;
      REA_JAVASCRIPT_PRLIMIT_COMMAND = runtimeTools.environment.REA_JAVASCRIPT_PRLIMIT_COMMAND;
      REA_EVM_PRLIMIT_COMMAND = runtimeTools.environment.REA_EVM_PRLIMIT_COMMAND;
    }
    // optionalAttrs usesJdk {
      JAVA_HOME = "${pkgs.jdk21.home}";
    };
in
{
  options.programs.rea = {
    enable = mkEnableOption "REA reverse-engineering tools";

    package = mkOption {
      type = types.package;
      default = bareRea;
      defaultText = lib.literalExpression "urio-nur.packages.${pkgs.system}.rea-agents";
      description = "The REA CLI and MCP server package.";
    };

    ghidra = {
      enable = mkEnableOption "Ghidra support in REA and the Ghidra CLI";

      package = mkOption {
        type = types.package;
        default = pkgs.ghidra;
        defaultText = lib.literalExpression "pkgs.ghidra";
        description = "Ghidra package to install and expose to REA.";
      };
    };

    freeTools = {
      enable = mkEnableOption "all free optional REA tools except Ghidra";

      chromium.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install Chromium for browser and Electron analysis.";
      };

      androidTools.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install Android platform tools (adb).";
      };

      apktool.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install Apktool for Android resource analysis.";
      };

      jadx.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install the pinned JADX MCP JAR and JDK for Android code analysis.";
      };

      ilspycmd.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install ILSpy command-line support for .NET analysis.";
      };

      binwalk.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install Binwalk for firmware inspection and extraction.";
      };

      unblob.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install Unblob for firmware extraction.";
      };

      mitmproxy.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install mitmproxy's mitmdump for browser traffic capture.";
      };

      wakaru.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install Wakaru for JavaScript recovery.";
      };

      pwntools.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install the pinned pwntools, pyelftools, and Unicorn environment.";
      };

      pwndbg.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install the portable pwndbg/GDB environment.";
      };

      prlimit.enable = mkOption {
        type = types.bool;
        default = free.enable;
        description = "Install util-linux prlimit for bounded REA subprocesses.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          pkgs.stdenv.hostPlatform.system == "x86_64-linux"
          || !(free.wakaru.enable || free.pwntools.enable || free.pwndbg.enable);
        message = "REA Wakaru, pwntools, and pwndbg bundles are currently supported only on x86_64-linux.";
      }
    ];

    home.packages = [
      cfg.package
    ]
    ++ optional cfg.ghidra.enable cfg.ghidra.package
    ++ freeToolPackages;

    home.sessionVariables =
      optionalAttrs cfg.ghidra.enable {
        GHIDRA_INSTALL_DIR = "${cfg.ghidra.package}/lib/ghidra";
        REA_ANALYSIS_PROVIDER = "auto";
      }
      // freeToolEnvironment;
  };
}
