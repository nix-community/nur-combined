{ lib
, llvmPackages_15
, fetchFromGitHub
, buildGoModule
}:
buildGoModule rec {
  pname = "dae";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = pname;
    rev = "c578f2af36d0d66d503224ffcad3a1a1d9e47286";
    sha256 = "sha256-PRz1EJZXmildxP9MgVxpWwvJUyKXbBDDwEbck3VblI0=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-2KKlbhJtoHUa02juXuS1QgvDD5LA5Tg/f0hNFscLJIQ=";

  proxyVendor = true;

  GOFLAGS = "-buildvcs=false";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/daeuniverse/dae/cmd.Version=${version}"
    "-X github.com/daeuniverse/dae/common/consts.MaxMatchSetLen_=64"
  ];

  preBuild = ''
    unset STRIP
    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector" \
    CLANG=${lib.getExe llvmPackages_15.clang} \
    ebpf
  '';

  doCheck = false;

  meta = with lib; {
    description = "dae";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    #    maintainers = with maintainers; [ oluceps ];
  };
}
