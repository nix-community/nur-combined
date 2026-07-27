{ callPackage, omnetpp_6_0 }: {
  omnetpp-inet_4_2_5 = callPackage (import ./common.nix {
    version = "4.2.5";
    sha256 = "sha256-ThMz014tXjVa/OUL4xUm7Xyw/4X5QCNwSzzg3nzbIz4=";
  }) { };
  omnetpp-inet_4_3_9 = callPackage (import ./common.nix {
    version = "4.3.9";
    sha256 = "sha256-2lvPxoKoRDNFvZCqNO0k4on6RsN0qVeLGxUfpA86qy0=";
  }) { omnetpp = omnetpp_6_0; };
}
