{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      surtsey = {
        hostname = "192.168.8.203";
        user = "marx";
        identityFile = ["~/.ssh/surtsey"];
      }; 
    };
  };
}
