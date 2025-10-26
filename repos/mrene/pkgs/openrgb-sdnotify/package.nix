{ openrgb, systemd }:

openrgb.overrideAttrs (old: {
  patches = [./0001-sd_notify.patch];
  buildInputs = old.buildInputs ++ [systemd];
  meta = old.meta // {
    description = "OpenRGB is a utility designed to manage RGB lighting for devices supporting the OpenRGB SDK (with systemd SD_NOTIFY patch)";
    # Broken due to upstream OpenRGB Qt 6 API compatibility issues in nixpkgs
    broken = true;
  };
})
