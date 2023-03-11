{ self, ... }:

{
  perSystem = { self', ... }:
    {
      apps = self.lib.makeApps self'.packages self.lib.appNames;
    };
}
