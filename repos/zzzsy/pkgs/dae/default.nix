{
  lib,
  clang,
  buildGoModule,
  source,
}:
buildGoModule rec {
  inherit (source) pname src date;
  version = "unstable-${date}";

  proxyVendor = true;
  vendorHash = "sha256-3H1IPjVqNraEUKLy6y2+iXeKLtuv5caHOJxUYa8lc20=";

  nativeBuildInputs = [ clang ];

  hardeningDisable = [ "zerocallusedregs" ];

  buildPhase = ''
    runHook preBuild

    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
    NOSTRIP=y \
    VERSION=${version} \
    OUTPUT=$out/bin/dae

    runHook postBuild
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
}
