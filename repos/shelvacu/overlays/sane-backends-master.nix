self: super:
let
  disabled = true;
  inherit (self) lib;
  patchesToIgnore = [
    "fbf80b0fc1d262ed40d4b49dd53c14707083ef60.patch"
    "8acc267d5f4049d8438456821137ae56e91baea9.patch"
  ];
in
if disabled then
  { }
else
  {
    sane-backends = super.sane-backends.overrideAttrs (oldAttrs: {
      version = "1.4.1-unstable-2026-03-29";

      src = self.fetchFromGitLab {
        owner = "sane-project";
        repo = "backends";
        rev = "a1386f77705eb9708628a0c000359a3cfa7364cb";
        hash = "sha256-d4wH6H8HpLuKPFCOhwio0060t8fx5BaCrf7TFmxnG3Q=";
      };

      patches = builtins.filter (
        patch: builtins.all (ignoreSuffix: !lib.hasSuffix ignoreSuffix (toString patch)) patchesToIgnore
      ) oldAttrs.patches;
    });
  }
