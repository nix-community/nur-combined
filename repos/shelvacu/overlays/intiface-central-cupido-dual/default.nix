final: prev: {
  # buttplug only drives one of the Cupido's two motors, and never re-finds BLE devices that drop out
  intiface-central =
    if prev.intiface-central.version == "3.0.4+40" then
      # buttplug source is let-bound in the package, so patch it via fetchFromGitHub
      prev.intiface-central.override {
        fetchFromGitHub =
          args:
          let
            src = prev.fetchFromGitHub args;
          in
          if args.repo == "buttplug" then
            prev.applyPatches {
              name = "buttplug-cupido-dual-source";
              inherit src;
              patches = [
                ./cupido.patch
                ./btleplug-reconnect.patch
              ];
            }
          else
            src;
      }
    else
      prev.intiface-central;
}
