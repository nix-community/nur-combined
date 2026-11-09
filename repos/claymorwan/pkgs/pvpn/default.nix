{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  nftables,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "pvpn";
  version = "0.2.12";

  src = fetchFromGitHub {
    owner = "YourDoritos";
    repo = "pVPN";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ssfi8ihwHgmPywfiRwKIcPYPJgTaQs8IWlsVn9xIPn0=";
  };

  vendorHash = "sha256-CGskLbX36xBRHqzU+tBtci80yLpfWlSpOAosO3tujXc=";

  ldflags = [
    "-s"
    "-w"
    "-X 'main.version=${finalAttrs.version}'"
  ];

  subPackages = [
    "cmd/pvpnd"
    "cmd/pvpn"
    "cmd/pvpnctl"
  ];

  env.CGO_ENABLED = 0;

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram $out/bin/pvpnd \
      --prefix PATH : ${lib.makeBinPath [ nftables ]}
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=v(\\d+\\.\\d+\\.\\d+)" ];
  };

  meta = {
    description = "Unofficial Proton VPN client for Linux";
    homepage = "https://github.com/YourDoritos/pVPN";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ claymorwan ];
  };
})
