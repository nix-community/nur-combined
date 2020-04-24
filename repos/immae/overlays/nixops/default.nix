self: super: {
  nixops = super.nixops.overrideAttrs (old: {
    patches = [
        ./fix_glibc.patch
        (self.fetchpatch {
          name = "hetzner_cloud.patch";
          url = "https://github.com/goodraven/nixops/commit/272e50d0b0262e49cdcaad42cdab57aad183d1c2.patch";
          sha256 = "12wcrb0155ald52m7fbr2m5rrxdnwdwripq91ckscgsk42mdc517";
        })
       ];
    preConfigure = (old.preConfigure or "") + ''
      sed -i -e '/^import sys$/s/$/; sys.tracebacklimit = 0/' scripts/nixops
      sed -i -e "/'keyFile'/s/'path'/'string'/" nixops/backends/__init__.py
      '';
  });
}
