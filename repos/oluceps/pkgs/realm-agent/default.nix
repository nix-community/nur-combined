{
  lib,
  buildGoModule,
  llvmPackages,
  libbpf,
  linuxHeaders,
}:
buildGoModule {
  pname = "realm-agent";
  version = "0.1.0";
  src = lib.cleanSource ./.;
  vendorHash = "sha256-UzNf821jBGWvZzY9BHE30xUfmu27nRYnu+4/USaZV/I=";
  env.CGO_ENABLED = "0";
  nativeBuildInputs = [ llvmPackages.clang-unwrapped ];
  preBuild = ''
    BPF_CLANG=${llvmPackages.clang-unwrapped}/bin/clang bash generate.sh \
      -I${libbpf}/include -I${linuxHeaders}/include \
      -fdebug-prefix-map=${libbpf}=/usr \
      -fdebug-prefix-map=${linuxHeaders}=/usr -fdebug-prefix-map="$PWD"=.
  '';
  ldflags = [
    "-s"
    "-w"
  ];
  meta = {
    description = "Host agent for cgroup BPF capture into SPIFFE-authenticated Realm egress";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "realm-agent";
  };
}
