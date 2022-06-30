{
  pkgs,
  sources,
  haskellNix,
}:
haskellNix.project {
  inherit (sources.taffybar) src;
  projectFileName = "stack.yaml";
}
