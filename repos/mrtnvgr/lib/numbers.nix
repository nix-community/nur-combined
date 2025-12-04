{ pkgs }: {
  relu = x: pkgs.lib.max 0 x;
}
