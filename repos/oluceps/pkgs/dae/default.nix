{ lib
, llvm_15
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

  preBuild = ''
    unset STRIP
    CLANG=${lib.getExe llvmPackages_15.clang} \
    CFLAGS="-O2 -Wall -D__REMOVE_BPF_PRINTK -fno-stack-protector" \
    BPF_CLANG=$CLANG \
    BPF_STRIP_FLAG="-strip=${llvm_15}/bin/llvm-strip" \
    BPF_CFLAGS=$CFLAGS \
    BPF_TARGET="bpfel,bpfeb" \
    go generate ./control/control.go
  '';

  vendorHash = "sha256-jrtJz+DKZarf/dlXaaVKtdTYzXFfwSyFkTvjxAzeMpg=";

  proxyVendor = true;

  doCheck = false;

  meta = with lib; {
    description = "dae";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    #    maintainers = with maintainers; [ oluceps ];
  };
}
