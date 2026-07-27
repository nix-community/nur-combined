{
  lib,
  clang,
  buildGoLatestModule,
  source,
}:

buildGoLatestModule (finalAttrs: {
  inherit (source) pname date src;

  version = "unstable-${finalAttrs.date}";

  vendorHash = "sha256-Bf2OgF3+dOC2LiD/2Y+g+tfc07ZctdRH/BAUO23fX6k=";

  proxyVendor = true;

  nativeBuildInputs = [ clang ];

  hardeningDisable = [ "zerocallusedregs" ];

  env.VERSION = finalAttrs.version;

  buildPhase = ''
    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
    NOSTRIP=y \
    OUTPUT=$out/bin/dae
  '';

  # network required
  doCheck = false;

  postInstall = ''
    install -Dm444 install/dae.service $out/lib/systemd/system/dae.service
    substituteInPlace $out/lib/systemd/system/dae.service \
      --replace /usr/bin/dae $out/bin/dae
  '';

  meta = with lib; {
    description = "A Linux high-performance transparent proxy solution based on eBPF";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "dae";
  };
})
