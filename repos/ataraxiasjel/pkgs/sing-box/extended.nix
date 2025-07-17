{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  coreutils,
  nix-update-script,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "sing-box-extended";
  version = "1.11.15-extended-1.3.1";

  src = fetchFromGitHub {
    owner = "shtorm-7";
    repo = "sing-box-extended";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XrGA0SGpul6LWzxlB9Jq92MurI3Fwp/HeiMw/8ED5ek=";
  };

  vendorHash = "sha256-BJWuHKfYxcnNEvwAJHFndSp0mJJCUZP0JIt+qAd3zwc=";

  tags = [
    "with_quic"
    "with_grpc"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_v2ray_api"
    "with_gvisor"
    # "with_embedded_tor"
    "with_tailscale"
  ];

  subPackages = [
    "cmd/sing-box"
  ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
  ];

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests = { inherit (nixosTests) sing-box; };
  };

  meta = {
    homepage = "https://github.com/shtorm-7/sing-box-extended";
    description = "Universal proxy platform";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    mainProgram = "sing-box";
  };
})
