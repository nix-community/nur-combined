{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.lua;
in
{
  options.nagy.lua = {
    enable = lib.mkEnableOption "lua config";
  };

  config = lib.mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/323016
    # https://github.com/NixOS/nixpkgs/issues/323083
    environment.systemPackages = [
      pkgs.lua5_4
      pkgs.luaformatter
      pkgs.lua-language-server

      pkgs.lua5_4.pkgs.fennel
    ];

    boot.binfmt.registrations.lua = {
      recognitionType = "extension";
      magicOrExtension = "lua";
      interpreter = pkgs.lua5_4.interpreter;
    };
    # byte code variant
    boot.binfmt.registrations.luac = {
      recognitionType = "extension";
      magicOrExtension = "lua";
      interpreter = pkgs.lua5_4.interpreter;
    };

    # This block can unfortunately not be used because luac
    # outputs it internal addresses which cause a different output every time.
    # For Example:
    # -function <file.lua:6,12> (28 instructions at 0x26134230)
    # +function <file.lua:6,12> (28 instructions at 0x2c511220)
    #
    # programs.git = {
    #   config = {
    #     diff = {
    #       luac = {
    #         textconv = "${pkgs.lua5_4}/bin/luac -p -l -";
    #         binary = true;
    #       };
    #     };
    #   };
    # };
    # environment.etc.gitattributes = {
    #   text = lib.mkAfter ''
    #     *.luac diff=luac
    #   '';
    # };

  };
}
