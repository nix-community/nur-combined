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
    rev = "066e856163413f92191106574f70f37cca56e8a3";
    sha256 = "sha256-N9nxkNlXXgLeJQyKVSUffFL7cU4HfGkpEKwkgLmhWvw=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-xL2X07CUj/37OIyb30l892yHuRiq3YXopfUS99x68do=";

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
