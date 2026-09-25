# Shared builder for all sing-box variants.
{
  lib,
  buildGoModule,
  installShellFiles,
  coreutils,
  lld,
  nix-update-script,
  nixosTests,

  pname,
  version,
  src,
  vendorHash,
  homepage,
  description ? "Universal proxy platform",
  baseTags ? [
    "with_gvisor"
    "with_quic"
    "with_grpc"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_v2ray_api"
    "with_tailscale"
    "with_ccm"
    "with_ocm"
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ],
  extraTags ? [ ],
  updateExtraArgs ? null,
  withCGO ? false,
}:

buildGoModule (finalAttrs: {
  inherit pname version;

  __structuredAttrs = true;

  inherit src;
  inherit vendorHash;

  env = {
    CGO_ENABLED = if withCGO then 1 else 0;
  }
  // lib.optionalAttrs withCGO {
    # cronet's prebuilt static lib is only linkable with lld (bfd ld rejects
    # the archive); same as upstream's `build-naive env` (CGO_LDFLAGS=-fuse-ld=lld)
    CGO_LDFLAGS = "-fuse-ld=lld";
  };

  tags =
    baseTags
    ++ extraTags
    ++ [
      "badlinkname"
      "tfogo_checklinkname0"
    ]
    ++ lib.optionals withCGO [ "with_naive_outbound" ];

  subPackages = [
    "cmd/sing-box"
  ];

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals withCGO [ lld ];

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
    "-X=runtime.godebugDefault=multipathtcp=0,tlssha1=1"
    "-checklinkname=0"
  ];

  # no tests in sandbox
  doCheck = false;

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service

    install -Dm444 release/config/sing-box.rules $out/share/polkit-1/rules.d/sing-box.rules
    install -Dm444 release/config/sing-box-split-dns.xml $out/share/dbus-1/system.d/sing-box-split-dns.conf
  '';

  passthru = {
    updateScript = nix-update-script (
      lib.optionalAttrs (updateExtraArgs != null) { extraArgs = updateExtraArgs; }
    );
    tests = { inherit (nixosTests) sing-box; };
  };

  meta = {
    inherit homepage description;
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    mainProgram = "sing-box";
  };
})
