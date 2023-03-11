{ self, inputs, lib, ... }:

{
  flake = {
    overlays = import ../overlays // {
      linyinfeng = self.overlays.default;
      singleRepoNur = final: prev: {
        nur = lib.recursiveUpdate (prev.nur or { })
          (lib.recurseIntoAttrs {
            repos = lib.recurseIntoAttrs (self.overlays.linyinfeng final prev);
          });
      };
    };
  };

  perSystem = { self', ... }:
    {
      overlayAttrs.linyinfeng = lib.recurseIntoAttrs self'.legacyPackages;
    };
}
