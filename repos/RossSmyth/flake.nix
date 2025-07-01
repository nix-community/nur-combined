{
  outputs =
    {
      self,
    }:
    {
      overlays.default = final: _: {
        inherit (final.callPackage ./. { }) ;
      };
    };
}
