{self, ...}: {
  ciData = self.lib.ci.makeCiData self {
    config = {
      checks.groups = [
        [".*"]
      ];
      checks.setup = ["pre-commit"];
      packages.groups = [
        [".*"]
      ];
      hosts.groups = [
        [".*"]
      ];
    };
  };
}
