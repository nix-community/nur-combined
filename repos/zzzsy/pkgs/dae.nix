{
  lib,
  clang,
  buildGoLatestModule,
  source,
}:

buildGoLatestModule (finalAttrs: {
  inherit (source) pname date src;

  version = "unstable-${finalAttrs.date}";

  vendorHash = "sha256-6LftE/bxVL5pDKWmFtdHyaCDcs5j6DcITufQGXKiIWM=";

  proxyVendor = true;

  nativeBuildInputs = [ clang ];

  hardeningDisable = [ "zerocallusedregs" ];

  env.VERSION = finalAttrs.version;
  env.GOEXPERIMENT = "newinliner,simd";

  buildPhase = ''
    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
    NOSTRIP=y \
    OUTPUT=$out/bin/dae
  '';

  # network required
  doCheck = false;

  meta = with lib; {
    description = "A Linux high-performance transparent proxy solution based on eBPF";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "dae";
  };
})
