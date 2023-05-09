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
    rev = "15aab1fc02ed1d50a0f6ccd982f4ffcf5e46bd6c";
    sha256 = "sha256-3zVnJ88+K7GIDFEIum1qvDVJswxXrJTPlW1lYXgBedM=";
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
