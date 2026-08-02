{
  lib,
  commonConfig,
  octalToDecimal,
  renderShellCommand,
  resolveAccount,
}: spec: let
  account = resolveAccount "darwin" spec.account;
  validUid =
    account
    != null
    && builtins.isInt account.platformAccount.uid
    && account.platformAccount.uid >= 502;
  validGid =
    account
    != null
    && builtins.isInt account.platformAccount.gid
    && account.platformAccount.gid >= 502;
  accountConfig = lib.optionalAttrs (account != null && account.manage) {
    users.knownGroups = [account.groupName];
    users.knownUsers = [account.userName];

    users.groups.${account.groupName} =
      lib.recursiveUpdate {
        gid = account.platformAccount.gid;
        description = "${account.description} group";
      }
      account.platformAccount.groupConfig;

    users.users.${account.userName} =
      lib.recursiveUpdate {
        uid = account.platformAccount.uid;
        gid = account.platformAccount.gid;
        inherit (account) description;
        home = account.home;
        createHome = account.createHome;
        isHidden = account.platformAccount.isHidden;
        shell = account.platformAccount.shell;
      }
      account.platformAccount.userConfig;
  };

  keepAlive =
    if spec.lifecycle.restart == "no"
    then null
    else if spec.lifecycle.restart == "always"
    then true
    else {SuccessfulExit = false;};

  generatedService = {
    command = renderShellCommand spec.process;
    environment = spec.process.environment;
    serviceConfig = lib.filterAttrs (_: value: value != null) ({
        UserName =
          if account == null
          then null
          else account.userName;
        GroupName =
          if account == null
          then null
          else account.groupName;
        WorkingDirectory = spec.process.workingDirectory;
        RunAtLoad = spec.lifecycle.autostart;
        KeepAlive = keepAlive;
        ThrottleInterval =
          if spec.lifecycle.restart == "no"
          then null
          else spec.lifecycle.restartBackoffSeconds;
        ExitTimeOut = spec.lifecycle.stopTimeoutSeconds;
        Umask =
          if spec.process.umask == null
          then null
          else octalToDecimal spec.process.umask;
        StandardOutPath = spec.darwin.standardOutPath;
        StandardErrorPath = spec.darwin.standardErrorPath;
      }
      // spec.darwin.serviceConfig);
  };

  serviceConfig = lib.recursiveUpdate generatedService spec.darwin.extraConfig;
in
  lib.mkMerge [
    (commonConfig spec)
    {
      assertions = [
        {
          assertion = spec.lifecycle.autostart || spec.lifecycle.restart == "no";
          message = "system-service ${spec.name} cannot request nix-darwin restart management without autostart";
        }
        {
          assertion = account == null || !account.manage || validUid;
          message = "system-service ${spec.name} managed nix-darwin account requires a UID of at least 502";
        }
        {
          assertion = account == null || !account.manage || validGid;
          message = "system-service ${spec.name} managed nix-darwin account requires a GID of at least 502";
        }
      ];
    }
    accountConfig
    {launchd.daemons.${spec.name} = serviceConfig;}
  ]
