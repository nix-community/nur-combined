{
  ifNotNUR,
  loadPackages,
  ...
}:
loadPackages ./. {
  attic-telnyx-compatible = ifNotNUR;
}
