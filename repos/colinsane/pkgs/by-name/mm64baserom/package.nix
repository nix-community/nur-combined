# this derivation is consumed by the upstream `zelda64recomp` package via overlay/override.
# it replaces the upstream `requireFile` expression with an equivalent expression that's actually buildable (what a concept).
{ fetchzip }:
fetchzip {
  name = "mm.us.rev1.rom.z64";
  url = "https://serve.emulatorgames.net/roms/nintendo-64/Legend%20of%20Zelda,%20The%20-%20Majora's%20Mask%20(U)%20%5b!%5d.zip";
  hash = "sha256-W7aLDUxMVx57JgjNIowF5a94mJ+qHaHIybK3m1jOWBc=";
  # .zip contains a single .z64 file inside it: move that to the toplevel, as expected by zelda64recomp package.
  postFetch = ''
    mv $out/* mm.us.rev1.rom.z64
    rmdir $out
    mv mm.us.rev1.rom.z64 $out
  '';
}
