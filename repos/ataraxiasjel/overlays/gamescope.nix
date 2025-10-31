_final: prev: {
  gamescope = prev.gamescope.overrideAttrs (oa: {
    patches = oa.patches or [ ] ++ [
      (prev.fetchpatch2 {
        name = "kill_then_wait_for_child_in_reverse.patch";
        url = "https://github.com/zlice/gamescope/commit/fa900b0694ffc8b835b91ef47a96ed90ac94823b.patch?full_index=1";
        hash = "sha256-Nagl95FbJgVSRbX/tW/+bsbyFHTLmU8KfF2WHylFuuY=";
      })
    ];
  });
  gamescope-wsi = prev.gamescope-wsi.overrideAttrs (oa: {
    patches = oa.patches or [ ] ++ [
      (prev.fetchpatch2 {
        name = "kill_then_wait_for_child_in_reverse.patch";
        url = "https://github.com/zlice/gamescope/commit/fa900b0694ffc8b835b91ef47a96ed90ac94823b.patch?full_index=1";
        hash = "sha256-Nagl95FbJgVSRbX/tW/+bsbyFHTLmU8KfF2WHylFuuY=";
      })
    ];
  });
}
