{
  openvswitch,
  dpdk,
  numactl,
  libpcap,
}:
openvswitch.overrideAttrs (old: rec {
  pname = "openvswitch-dpdk";

  buildInputs = (old.buildInputs or [ ]) ++ [
    dpdk
    numactl
    libpcap
  ];

  configureFlags = (old.configureFlags or [ ]) ++ [ "--with-dpdk=shared" ];

  doCheck = false;

  meta = old.meta // {
    mainProgram = "ovs-vsctl";
    knownVulnerabilities = [
      "${pname} is available in nixpkgs"
    ];
  };
})
