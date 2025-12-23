{
  self,
  withSystem,
  ...
}:
{
  flake = {
    overlay = self.overlays.default;
    overlays.default =
      final: prev: withSystem prev.stdenv.hostPlatform.system ({ self', ... }: self'.packages);
  };
}
