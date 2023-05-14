{ lib
, llvmPackages_15
, fetchFromGitHub
, buildGoModule
}:
buildGoModule rec {
  pname = "dae";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = pname;
    rev = "5ae3d90cfb38374d32f328c6522c5ddfc4686b19";
    sha256 = "sha256-pttPIFE7GlHle3fLUF0MlD3po22ug4lzW7RwKZc2HLE=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-4LfnU3UCNhMBloSCUUXrseiUT6esqWFngrGIFjpAjUc=";

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
