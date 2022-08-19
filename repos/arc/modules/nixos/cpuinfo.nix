{ config, lib, ... }: with lib; let
  cfg = config.hardware.cpu.info;
in {
  options.hardware.cpu = {
    info = {
      vendorId = mkOption {
        type = with types; oneOf [ (enum [ "AuthenticAMD" "GenuineIntel" ]) str ];
      };
      modelName = mkOption {
        type = types.str;
      };
      sockets = mkOption {
        type = types.int;
        default = 1;
      };
      cores = mkOption {
        type = types.int;
        description = "cores per socket";
      };
      threadsPerCore = mkOption {
        type = types.int;
      };
      processorCount = mkOption {
        type = types.int;
        default = cfg.sockets * cfg.cores * cfg.threadsPerCore;
      };
      coreLayout = mkOption {
        type = types.enum [ "amd-legacy" "intel" ];
        default = "intel";
      };
      processors = let
        coreList = genList id cfg.cores;
        cores = {
          intel = concatLists (genList (threadId: map (coreId: {
            inherit threadId coreId;
          }) coreList) cfg.threadsPerCore);
          amd-legacy = concatMap (coreId: genList (threadId: {
            inherit threadId coreId;
          }) cfg.threadsPerCore) coreList;
        }.${cfg.coreLayout};
      in mkOption {
        type = with types; listOf attrs;
        default = imap0 (processorId: core: core // {
          inherit processorId;
        }) cores;
        readOnly = true;
      };
    };
  };
}
