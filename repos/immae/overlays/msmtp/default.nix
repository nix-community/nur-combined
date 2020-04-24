self: super: {
  msmtp = super.msmtp.overrideAttrs(old: {
    patches = old.patches ++ [
      (super.fetchpatch {
        url = "https://github.com/marlam/msmtp-mirror/commit/c78f24347ec996c7a3830b48403bf3736afca071.patch";
        sha256 = "0d4sc2f5838jriv65wahpgvwckkzqhdk3hs660fyg80si2i0l1bx";
      })
    ];
  });
}
