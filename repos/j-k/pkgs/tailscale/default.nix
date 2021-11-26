{ lib, stdenv, buildGoModule, go_1_17, fetchFromGitHub, makeWrapper, iptables, iproute2, procps }:

buildGoModule.override { go = go_1_17; } rec {
  pname = "tailscale";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tailscale";
    rev = "v${version}";
    sha256 = "sha256-x56TB+rkZZtZuBt8EcCqJnwZxwBhItZfH7dmi5Jfyw0=";
  };
  vendorSha256 = "1mwdi37rfxf15p95qmqlfb58xpx08df9042pdzk4sqnmq837sqzi";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ makeWrapper ];

  CGO_ENABLED = 0;

  subPackages = [ "cmd/tailscale" "cmd/tailscaled" ];

  tags = [ "xversion" ];

  ldflags = [ "-X tailscale.com/version.Long=${version}" "-X tailscale.com/version.Short=${version}" ];

  doCheck = false;

  postInstall = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/tailscaled --prefix PATH : ${lib.makeBinPath [ iproute2 iptables ]}
    wrapProgram $out/bin/tailscale --suffix PATH : ${lib.makeBinPath [ procps ]}
    sed -i -e "s#/usr/sbin#$out/bin#" -e "/^EnvironmentFile/d" ./cmd/tailscaled/tailscaled.service
    install -D -m0444 -t $out/lib/systemd/system ./cmd/tailscaled/tailscaled.service
  '';

  meta = with lib; {
    homepage = "https://tailscale.com";
    description = "The node agent for Tailscale, a mesh VPN built on WireGuard";
    license = licenses.bsd3;
    maintainers = with maintainers; [ danderson mbaillie jk ];
  };
}
