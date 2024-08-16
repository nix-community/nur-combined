{
  openvswitch,
  dpdk,
  numactl,
  libpcap,
}:
openvswitch.overrideAttrs (old: {
  pname = "openvswitch-dpdk";

  buildInputs = (old.buildInputs or [ ]) ++ [
    dpdk
    numactl
    libpcap
  ];

  configureFlags = (old.configureFlags or [ ]) ++ [ "--with-dpdk=shared" ];

  doCheck = false;
})
