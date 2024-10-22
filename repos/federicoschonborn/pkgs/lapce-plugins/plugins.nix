{ lib, mkLapcePlugin }:

builtins.listToAttrs (
  builtins.map (plugin: {
    inherit (plugin) name;
    value = mkLapcePlugin (
      builtins.removeAttrs plugin [ "description" ]
      // {
        meta = {
          inherit (plugin) description;
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.federicoschonborn ];
        };
      }
    );
  }) (lib.importJSON ./plugins.json)
)
