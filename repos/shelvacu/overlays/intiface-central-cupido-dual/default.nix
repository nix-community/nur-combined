final: prev:
let
  # buttplug only drives one of the Cupido's two motors, and never re-finds BLE devices that drop out
  inherit (prev.intiface-central) version;

  # 3.0.4 builds buttplug from a path dep, so patch that source
  patchButtplugSource = prev.intiface-central.override (old: {
    fetchFromGitHub =
      args:
      let
        src = old.fetchFromGitHub args;
      in
      if args.repo == "buttplug" then
        prev.applyPatches {
          name = "buttplug-cupido-dual-source";
          inherit src;
          patches = [
            ./engine-4.0.2/cupido.patch
            ./engine-4.0.2/btleplug-reconnect.patch
            ./engine-4.0.2/cupido-patterns-battery.patch
          ];
        }
      else
        src;
  });

  # 3.2.2 takes buttplug from crates.io; patch the vendored crates (named <crate>-<version>.patch)
  patchVendoredCrates = prev.intiface-central.override (old: {
    rustPlatform = old.rustPlatform // {
      buildRustPackage =
        args:
        old.rustPlatform.buildRustPackage (
          args
          // {
            postPatch = (args.postPatch or "") + ''
              for p in ${./crates-3.2.2}/*.patch; do
                patch -p1 -d "$cargoDepsCopy/source-registry-0/$(basename "$p" .patch)" < "$p"
              done
            '';
          }
        );
    };
  });
in
{
  intiface-central =
    if version == "3.0.4+40" then
      patchButtplugSource
    else if version == "3.2.2+46" then
      patchVendoredCrates
    else
      prev.intiface-central;
}
