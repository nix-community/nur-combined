{
  i3workspaceoutput = import ./i3workspaceoutput;
  getquote-alphavantage = import ./getquote-alphavantage.nix;
  konawall = import ./konawall;
  benc = import ./benc;
  qemucomm = import ./qemucomm.nix;
  filebin = import ./filebin;
  winpath = import ./winpath.nix;
  task-blocks = import ./task-blocks.nix;
} // (import ./yggdrasil-7n/default.nix)
