self: _super: {
  fetchurlWithWetransfer =
    args:
    (self.fetchurl args).overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ ./convert-wetransfer-links.sh ];
      env.transferweeBin = self.lib.getExe self.transferwee;
      env.NIX_DEBUG = "6";
    });
}
