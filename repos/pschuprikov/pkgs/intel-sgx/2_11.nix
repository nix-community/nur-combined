import ./generic.nix {
  version = "2.11";
  hasMitigation = true;
  sha256 = "0nrz9wcvyccchwygxa6ng9726l9wlpf7f3nsblff2xwhsq6q1312";
  optlibsSha256 = "0qki299mxdp937vwg3163c79qj9976hdd6qs72j7h7jc25chiba3";
  binutilsSha256 = "1q1mf7p8xvwfkvw0fkvbv28q3wffwaz9c96s7hqv7r3095cj7xlp";
  aeSha256 = "ggxxP2tFMbe6R1/bKI1hZkcnfVqxYBmYxtxQ12G4hp4=";
  patchOpenMP = true;
}

