{
  lib,
  pkgs,
  systemdUtils ? null,
}: let
  accountDefaults = {
    manage = true;
    createHome = true;
    nixos = {
      userConfig = {};
      groupConfig = {};
    };
    darwin = {
      uid = null;
      gid = null;
      isHidden = true;
      shell = "/usr/bin/false";
      userConfig = {};
      groupConfig = {};
    };
  };

  specDefaults = {
    packages = [];
    process = {
      arguments = [];
      environment = {};
      workingDirectory = null;
      umask = null;
    };
    account = null;
    lifecycle = {
      autostart = true;
      restart = "on-failure";
      restartBackoffSeconds = 5;
      stopTimeoutSeconds = 90;
    };
    nixos = {
      wantedBy = null;
      wants = [];
      requires = [];
      after = [];
      serviceConfig = {};
      extraConfig = {};
    };
    darwin = {
      standardOutPath = null;
      standardErrorPath = null;
      serviceConfig = {};
      extraConfig = {};
    };
  };

  normalize = spec: let
    normalized = lib.recursiveUpdate specDefaults spec;
    account =
      if spec.account or null == null
      then null
      else lib.recursiveUpdate accountDefaults spec.account;
  in
    normalized // {inherit account;};

  resolveAccount = platform: account:
    if account == null
    then null
    else let
      platformAccount = account.${platform};
      defaultName =
        if platform == "darwin"
        then "_${account.logicalName}"
        else account.logicalName;
      defaultGroupName =
        if platform == "darwin"
        then "_${account.groupLogicalName or account.logicalName}"
        else account.groupLogicalName or account.logicalName;
    in
      account
      // {
        inherit platformAccount;
        userName = platformAccount.userName or defaultName;
        groupName = platformAccount.groupName or defaultGroupName;
      };

  commandArguments = process:
    [process.executable] ++ process.arguments;

  renderShellCommand = process:
    lib.escapeShellArgs (map toString (commandArguments process));

  renderSystemdCommand = process:
    if systemdUtils == null
    then throw "system-service mkNixos requires the NixOS module argument `utils`"
    else systemdUtils.escapeSystemdExecArgs (commandArguments process);

  octalDigits = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
  };

  octalToDecimal = value:
    if builtins.match "^[0-7]{3,4}$" value == null
    then throw "system-service umask must contain three or four octal digits"
    else
      lib.foldl'
      (result: digit: result * 8 + octalDigits.${digit})
      0
      (lib.stringToCharacters value);

  commonConfig = spec: let
    invalidEnvNames = builtins.filter (
      name: builtins.match "^[A-Za-z_][A-Za-z0-9_]*$" name == null
    ) (builtins.attrNames spec.process.environment);
    invalidEnvValues = lib.filterAttrs (_: value: !builtins.isString value) spec.process.environment;
    invalidArguments = builtins.filter (argument: !builtins.isString argument) spec.process.arguments;
    workingDirectory = spec.process.workingDirectory;
    account = spec.account;
  in {
    assertions = [
      {
        assertion = builtins.match "^[A-Za-z0-9_.@-]+$" spec.name != null;
        message = "system-service name contains unsupported characters: ${spec.name}";
      }
      {
        assertion = lib.hasPrefix "/" (toString spec.process.executable);
        message = "system-service ${spec.name} executable must be an absolute path";
      }
      {
        assertion = invalidArguments == [];
        message = "system-service ${spec.name} arguments must all be strings";
      }
      {
        assertion = invalidEnvNames == [];
        message = "system-service ${spec.name} environment contains invalid variable names: ${lib.concatStringsSep ", " invalidEnvNames}";
      }
      {
        assertion = invalidEnvValues == {};
        message = "system-service ${spec.name} environment values must all be strings";
      }
      {
        assertion = workingDirectory == null || lib.hasPrefix "/" (toString workingDirectory);
        message = "system-service ${spec.name} working directory must be an absolute path";
      }
      {
        assertion = spec.process.umask == null || builtins.match "^[0-7]{3,4}$" spec.process.umask != null;
        message = "system-service ${spec.name} umask must contain three or four octal digits";
      }
      {
        assertion = builtins.elem spec.lifecycle.restart ["no" "always" "on-failure"];
        message = "system-service ${spec.name} has an unsupported restart policy: ${spec.lifecycle.restart}";
      }
      {
        assertion = spec.lifecycle.restartBackoffSeconds >= 0;
        message = "system-service ${spec.name} restart backoff must not be negative";
      }
      {
        assertion = spec.lifecycle.stopTimeoutSeconds >= 0;
        message = "system-service ${spec.name} stop timeout must not be negative";
      }
      {
        assertion = builtins.all (lib.meta.availableOn pkgs.stdenv.hostPlatform) spec.packages;
        message = "system-service ${spec.name} contains a package unavailable on ${pkgs.stdenv.hostPlatform.system}";
      }
      {
        assertion =
          account
          == null
          || !account.manage
          || (account.home
            != null
            && (account.home == workingDirectory || lib.hasPrefix "/" (toString account.home)));
        message = "system-service ${spec.name} managed account requires an absolute home directory";
      }
    ];

    environment.systemPackages = spec.packages;
  };

  renderNixos = import ./nixos.nix {
    inherit lib commonConfig renderSystemdCommand resolveAccount;
  };

  renderDarwin = import ./darwin.nix {
    inherit lib commonConfig octalToDecimal renderShellCommand resolveAccount;
  };
in {
  mkSpec = normalize;
  mkNixos = spec: renderNixos (normalize spec);
  mkDarwin = spec: renderDarwin (normalize spec);
}
