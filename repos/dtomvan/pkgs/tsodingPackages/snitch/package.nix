{
  lib,
  nix-update-script,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "snitch";
  version = "0-unstable-2021-11-24";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "snitch";
    rev = "da4c8d5c1ca9b7d72dcdaa61f9d93bc2e12b7a5e";
    hash = "sha256-M3FZs4GL0AXXUFH+VHFTI12aZx12RfgOWJltU6sOMfw=";
  };

  vendorHash = "sha256-QAbxld0UY7jO9ommX7VrPKOWEiFPmD/xw02EZL6628A=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Finds TODOs in source code and reports them as issues";
    homepage = "https://github.com/tsoding/snitch";
    license = lib.licenses.mit;
    mainProgram = "snitch";
  };
}
