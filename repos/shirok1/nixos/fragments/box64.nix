{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    types
    optionalString
    concatStringsSep
    escapeShellArgs
    ;

  cfg = config.boot.binfmt.box64;

  # system/box64.conf.cmake
  x86_64Magic = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
  x86_64Mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';

  interpreterWrapper = lib.getExe cfg.package;
  # 生成一个实际的 interpreter（放到 store），然后交给内置模块去 symlink 到 /run/binfmt/<name>
  # interpreterWrapper =
  #   pkgs.writeShellScript "box64-binfmt-interpreter" ''
  #     #!${pkgs.bash}/bin/sh
  #     # set -euo pipefail

  #     # binfmt_misc 默认行为（无 P）：$1 是被执行的目标二进制路径，后续为原始参数
  #     # 这里将其转交给 box64
  #     ${concatStringsSep "\n" (map (k: "export ${k}=${lib.escapeShellArg cfg.environment.${k}}") (builtins.attrNames cfg.environment))}

  #     exec -- ${cfg.package}/bin/box64 ${escapeShellArgs cfg.extraArgs} "$@"
  #   '';
in
{
  options.boot.binfmt.box64 = {
    enable = mkEnableOption "Register box64 via boot.binfmt (binfmt_misc)";

    # 你可以替换为 overlay 提供的 box64；若 nixpkgs 已有 pkgs.box64 也可直接用默认。
    package = mkOption {
      type = types.package;
      default =
        pkgs.box64 or (throw "pkgs.box64 is not available; set boot.binfmt.box64.package explicitly.");
      description = "The box64 package providing bin/box64.";
    };

    registrationName = mkOption {
      type = types.str;
      default = "box64";
      description = "Name of the binfmt_misc registration (also used under /run/binfmt/<name>).";
    };

    # 识别规则：默认 x86_64 ELF
    magicOrExtension = mkOption {
      type = types.str;
      default = x86_64Magic;
      description = "ELF magic for the target binaries. Default matches x86_64 ELF.";
    };

    mask = mkOption {
      type = types.str;
      default = x86_64Mask;
      description = "Mask applied before matching the magic. Default matches x86_64 ELF.";
    };

    # flags/行为（直接映射到 boot.binfmt.registrations 子模块字段）
    preserveArgvZero = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to set the 'P' flag (preserve argv[0]) in binfmt_misc.";
    };

    openBinary = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to set the 'O' flag (pass opened FD) in binfmt_misc.";
    };

    matchCredentials = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to set the 'C' flag (match credentials). Requires openBinary = true.";
    };

    fixBinary = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to set the 'F' flag (open interpreter at registration time).";
    };

    # box64 运行时参数/环境
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "-v" ];
      description = "Extra arguments passed to box64 before the original program arguments.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        BOX64_LOG = "1";
        BOX64_DYNAREC = "1";
      };
      description = "Environment variables exported by the interpreter wrapper before launching box64.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.matchCredentials && !cfg.openBinary);
        message = "boot.binfmt.box64: matchCredentials = true requires openBinary = true (kernel binfmt_misc constraint).";
      }
      # 这是实践上常见约束：box64 通常用于非 x86_64 host（例如 aarch64）。
      # 如果你确实要在 x86_64 上注册，也可以删掉此断言。
      {
        assertion = pkgs.stdenv.hostPlatform.system != "x86_64-linux";
        message = "boot.binfmt.box64: registering box64 on x86_64-linux is usually unnecessary; remove this assertion if you know what you're doing.";
      }
    ];

    # 关键：只“产出” boot.binfmt.registrations，复用你给的内置模块去落地 /etc/binfmt.d、/run/binfmt 等
    boot.binfmt.registrations."${cfg.registrationName}" = {
      recognitionType = "magic";
      offset = 0;

      magicOrExtension = cfg.magicOrExtension;
      mask = cfg.mask;

      interpreter = interpreterWrapper;

      preserveArgvZero = cfg.preserveArgvZero;
      openBinary = cfg.openBinary;
      matchCredentials = cfg.matchCredentials;
      fixBinary = cfg.fixBinary;

      # 我们自己生成了一个可执行脚本作为 interpreter，因此不需要内置模块再包一层 shell
      wrapInterpreterInShell = true;

      # 给内置模块用于 nix sandbox 的可选路径暴露（它只在 emulatedSystems 分支里用到）。
      # 这里仍填一个合理默认，不会有副作用。
      interpreterSandboxPath = mkDefault (dirOf (dirOf interpreterWrapper));
    };

    nix.settings.extra-sandbox-paths = [
      "/run/binfmt"
      "${pkgs.bash}"
      "${cfg.package}"
      # "${pkgs.x86_64.bash}"
      # "/nix/store/lw117lsr8d585xs63kx5k233impyrq7q-bash-5.3p3"
    ];

    # 只有你确认需要 Nix 认为 x86_64 可执行时才加
    nix.settings.extra-platforms = [ "x86_64-linux" ];
  };
}
