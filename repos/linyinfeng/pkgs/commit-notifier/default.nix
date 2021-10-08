{ sources, rustPlatform, lib, pkg-config, openssl, libgit2, sqlite }:

let
  drv = rustPlatform.buildRustPackage
    rec {
      inherit (sources.commit-notifier) pname version src cargoLock;

      nativeBuildInputs = [
        pkg-config
      ];
      buildInputs = [
        openssl
        sqlite
        libgit2
      ];

      meta = with lib; {
        homepage = "https://github.com/linyinfeng/commit-notifier";
        description = "A simple telegram bot monitoring commit status";
        license = licenses.mit;
      };
    };
  broken = with lib; !(versionAtLeast (versions.majorMinor trivial.version) "21.11");
in
if broken
then
  (derivation
    {
      name = "dummy-broken-package";
      builder = "dummy-builder";
      system = "dummy-system";
    }) //
  {
    meta.broken = true;
  }
else
  drv
