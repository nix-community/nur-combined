{ lib, mkLapcePlugin }:

builtins.listToAttrs (
  builtins.map (attrs: {
    inherit (attrs) name;
    value = mkLapcePlugin (
      builtins.removeAttrs attrs [ "description" ]
      // {
        meta = {
          inherit (attrs) description;
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.federicoschonborn ];
        };
      }
    );
  }) (lib.importJSON ./plugins.json)
)
