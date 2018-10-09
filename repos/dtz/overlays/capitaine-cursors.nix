self: super: {
  capitaine-cursors = super.capitaine-cursors.overrideAttrs (o: {
    patches = (o.patches or []) ++ [
      # Support additional sizes
      (super.fetchpatch {
        url = "https://github.com/keeferrourke/capitaine-cursors/commit/46c3ffd3d818bce8094712f38577dc5f3a7e810a.patch";
        sha256 = "1vzq3rnr5q0wj4y2rxp8lk52j2z5d5n2j9jv4wqdl2vr81p8whg8";
      })
    ];
  });
}
