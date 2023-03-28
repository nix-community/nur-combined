{ lib
, llvmPackages_15
, fetchFromGitHub
, buildGoModule
}:
buildGoModule rec {
  pname = "dae";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = pname;
    rev = "cc50bea0fce75bae8b393fad54884300bf9e9c56";
    sha256 = "sha256-9cHJ9Usn0c5GBj1H6v0Dg1SdpvadvVh0Pd67maog/fM=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-jrtJz+DKZarf/dlXaaVKtdTYzXFfwSyFkTvjxAzeMpg=";

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
