{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  nftables,
}:

buildGoModule (finalAttrs: {
  pname = "pvpn";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "YourDoritos";
    repo = "pVPN";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BN8N+A1GIgFfnhAEZ1YgnfSW3/XYg15mYCwO+M2GBmk=";
  };

  vendorHash = "sha256-2iy3oRJuFcnBok/Pks9dSdq8ulbOpVW5D4aHawmqZmg=";

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

  meta = {
    description = "Unofficial Proton VPN client for Linux";
    homepage = "https://github.com/YourDoritos/pVPN";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ claymorwan ];
  };
})
