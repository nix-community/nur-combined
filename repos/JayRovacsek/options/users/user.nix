{ name, lib, ... }:
with lib; {
  options = {
    name = mkOption {
      type = types.str;
      description = ''
        The name of the user account. If undefined, the name of the
        attribute set will be used.
      '';
    };

    description = mkOption {
      type = types.str;
      default = "";
      example = "Alice Q. User";
      description = ''
        A short description of the user account, typically the
        user's full name.
      '';
    };

    uid = mkOption {
      type = types.int;
      description = "The user's UID.";
    };

    gid = mkOption {
      type = types.int;
      default = 20;
      description = "The user's primary group.";
    };

    isHidden = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to make the user account hidden.";
    };

    home = mkOption {
      type = types.path;
      default = "/Users/${name}";
      description = "The user's home directory.";
    };

    createHome = mkOption {
      type = types.bool;
      default = true;
      description = "Create the home directory when creating the user.";
    };

    shell = mkOption {
      type = with types; either shellPackage path;
      default = "${pkgs.zsh}/bin/zsh";
      example = literalExpression "${pkgs.bash}/bin/bash";
      description = "The user's shell.";
    };

    packages = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = literalExpression "[ firefox vscodium ]";
      description = ''
        The set of packages that should be made availabe to the user.
        This is in contrast to <option>environment.systemPackages</option>,
        which adds packages to all users.
      '';
    };
  };

  config.name = mkDefault name;
}
