{ pkgs, ... }:
{
  sane.programs.zelda64recomp = {
    # upstream package places non-binaries (e.g. art assets) in `bin/`;
    # this especially confuses my sandboxer.
    # so link only the files i want to be visible:
    packageUnwrapped = pkgs.linkIntoOwnPackage pkgs.zelda64recomp [
      "bin/Zelda64Recompiled"
      "share/applications"
      "share/icons"
    ] {};
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistX = true;  #< TODO: it uses SDL; i might be able to get it to run on wayland only

    sandbox.extraPaths = [
      "/dev/input"  #< for controllers (speculative)
    ];

    sandbox.mesaCacheDir = ".cache/Zelda64Recompiled/mesa";

    fs.".config/Zelda64Recompiled/mm.n64.us.1.0.z64".symlink.target = pkgs.mm64baserom;
    # also config files for: graphics.json, general.json, controls.json, sound.json

    persist.byStore.plaintext = [
      ".config/Zelda64Recompiled/saves"
    ];
  };
}
