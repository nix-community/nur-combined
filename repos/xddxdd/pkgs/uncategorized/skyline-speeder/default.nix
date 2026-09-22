{
  bpftools,
  libbpf,
  llvmPackages,
  coreutils,
  elfutils,
  fetchFromGitHub,
  lib,
  linuxPackages_6_12,
  nix-update-script,
  pkg-config,
  rustPlatform,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "skyline-speeder";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "CYBERVERSE-Research";
    repo = "skyline-speeder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nIYVHm7SJ267zpFrq0YgLOqU1gdsEj6PZC4cbnMrKp8=";
  };

  cargoHash = "sha256-l9+SQN4P/lSmYtMCDY0vi0akrcj9yVaipkdPQ0r7Kog=";

  nativeBuildInputs = [
    pkg-config
    llvmPackages.clang-unwrapped
    bpftools
  ];
  buildInputs = [
    elfutils
    zlib
  ];

  preBuild = ''
    make bpf BPFTOOL=bpftool BPF_CLANG=${llvmPackages.clang-unwrapped}/bin/clang BPF_CFLAGS="-O2 -g -target bpf -D__TARGET_ARCH_x86 -I${libbpf}/include" VMLINUX_BTF=${linuxPackages_6_12.kernel.dev}/vmlinux
  '';

  postInstall = ''
    install -Dm644 build/bpf/*.bpf.o -t $out/share/skyline-speeder/bpf
    install -Dm644 config/speeder.toml $out/share/skyline-speeder/config/speeder.toml
    sed -i "s|bpf_dir = \"build/bpf\"|bpf_dir = \"${placeholder "out"}/share/skyline-speeder/bpf\"|" \
      $out/share/skyline-speeder/config/speeder.toml

    for script in apply-guest-profile.sh collect-guest-metrics.sh snapshot-skyline-events.sh run-in-skyline-cgroup.sh boot-enable.sh boot-disable.sh; do
      install -Dm755 infra/$script $out/share/skyline-speeder/infra/$script
      if grep -qF "/usr/local/bin/ssctl" $out/share/skyline-speeder/infra/$script; then
        substituteInPlace $out/share/skyline-speeder/infra/$script \
          --replace-fail "/usr/local/bin/ssctl" "${placeholder "out"}/bin/ssctl"
      fi
    done

    substituteInPlace packaging/skyline-speederd.service \
      --replace-fail "/usr/local/sbin/skyline-speederd" "${placeholder "out"}/bin/skyline-speederd" \
      --replace-fail "/bin/mkdir" "${coreutils}/bin/mkdir"
    substituteInPlace packaging/skyline-speeder-enable.service \
      --replace-fail "/opt/skyline-speeder/infra/boot-enable.sh" "${placeholder "out"}/share/skyline-speeder/infra/boot-enable.sh" \
      --replace-fail "/opt/skyline-speeder/infra/boot-disable.sh" "${placeholder "out"}/share/skyline-speeder/infra/boot-disable.sh"
    for service in packaging/*.service; do
      install -Dm644 $service $out/lib/systemd/system/$(basename $service)
    done
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    mainProgram = "skyline-speederd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Sender-side TCP congestion control via eBPF struct_ops with a Rust control plane";
    homepage = "https://github.com/CYBERVERSE-Research/skyline-speeder";
    license = lib.licenses.gpl2Only;
    changelog = "https://github.com/CYBERVERSE-Research/skyline-speeder/blob/v${finalAttrs.version}/CHANGELOG.md";
    platforms = [ "x86_64-linux" ];
  };
})
