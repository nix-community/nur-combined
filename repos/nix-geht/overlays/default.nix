{
  # We need old DPDK 22.03 for VPP to work.
  # TODO: Once https://gerrit.fd.io/r/c/vpp/+/37840 is solved and a new VPP release happens - remove.
  old-dpdk = import ./dpdk-22.03.nix;
}
