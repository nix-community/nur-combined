{ lib
, llvmPackages_15
, fetchFromGitHub
, buildGoModule
}:
buildGoModule rec {
  pname = "dae";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = pname;
    rev = "6ff68e533e408abbb73e2a4bb1749303b2eaff06";
    sha256 = "sha256-lRrUlZcV6C3vpPFxQ327O1ioWLINRaXM5TsrH4/UYIo=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-euTgB660px8J/3D3n+jzyetzzs6uD6yrXGvIgqzQcR0=";

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
