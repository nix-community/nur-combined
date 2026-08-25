# Shared builder for every sing-box pre-release channel; each pkgs/sing-box-*/default.nix
# supplies its own nvfetcher source and gomod2nix lockfile.
{
  lib,
  buildGoApplication,
  buildPackages,
  coreutils,
  installShellFiles,
}: {
  source,
  modules,
  version,
}:
buildGoApplication {
  inherit (source) pname src;
  inherit version modules;

  subPackages = ["cmd/sing-box"];

  # Share the CGO setting with gomod2nix's dependency cache.
  # `with_naive_outbound` links the prebuilt libcronet.a that upstream ships as
  # the `cronet-go/lib/<platform>` modules, so cgo cannot be turned off here.
  CGO_ENABLED = "1";

  # That archive carries ThinLTO bitcode, which only lld can link.
  CGO_LDFLAGS = "-fuse-ld=lld";

  # release/DEFAULT_BUILD_TAGS minus with_cloudflared, with_usbip, with_openvpn
  # and with_openconnect, matching what this package built before gomod2nix.
  tags = [
    "with_gvisor"
    "with_quic"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_tailscale"
    "with_ccm"
    "with_ocm"
    "with_naive_outbound"
    "badlinkname"
    "tfogo_checklinkname0"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/sagernet/sing-box/constant.Version=${version}"
    # release/LDFLAGS; 1.14 renamed the knob from `internal/godebug.defaultGODEBUG`.
    "-X=runtime.godebugDefault=multipathtcp=0,tlssha1=1,tlsunsafeekm=1"
    "-checklinkname=0"
  ];

  nativeBuildInputs = [
    installShellFiles
    buildPackages.rustc.llvmPackages.bintools
  ];

  doCheck = true;

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service

    install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules
    install -Dm444 release/config/sing-box-split-dns.xml $out/share/dbus-1/system.d/sing-box-split-dns.conf

    install -Dm644 LICENSE README.md -t $out/share/doc/${source.pname}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    singBoxVersion="$($out/bin/sing-box version)"
    echo "$singBoxVersion"

    echo "$singBoxVersion" | grep -F 'sing-box version ${version}'
    # Both lines fail if the prebuilt cronet archive did not link.
    echo "$singBoxVersion" | grep -F 'with_naive_outbound'
    echo "$singBoxVersion" | grep -F 'CGO: enabled'

    $out/bin/sing-box --help >/dev/null

    test -f $out/share/doc/${source.pname}/LICENSE
    test -f $out/share/doc/${source.pname}/README.md

    runHook postInstallCheck
  '';

  meta = {
    description = "Universal proxy platform";
    homepage = "https://sing-box.sagernet.org";
    changelog = "https://github.com/SagerNet/sing-box/releases/tag/${source.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sing-box";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
