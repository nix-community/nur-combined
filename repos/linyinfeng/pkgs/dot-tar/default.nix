{ sources, rustPlatform, lib, pkg-config, openssl }:

let
  drv = rustPlatform.buildRustPackage
    rec {
      inherit (sources.dot-tar) pname version src cargoLock;

      nativeBuildInputs = [
        pkg-config
      ];
      buildInputs = [
        openssl
      ];

      meta = with lib; {
        homepage = "https://github.com/linyinfeng/dot-tar";
        description = "A tiny web server converting files to singleton tar files";
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
