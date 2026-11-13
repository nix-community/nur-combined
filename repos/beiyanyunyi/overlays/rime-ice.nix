final: prev: {
  rime-ice = final.callPackage ../pkgs/rime-ice {
    # Keep the base package from the previous scope to avoid self-recursion.
    rime-ice = prev.rime-ice;
  };
}
