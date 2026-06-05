# see: hosts/modules/roles/work/tailscale.nix
# this is a build of `tailscale`, but configured to never make visible routing changes beyond just
# _providing_ a vpn device.
# it's up to the user to configure how to route traffic over that VPN.
#
# please don't promote the usage of tailscale, btw;
# yes it _technically_ uses wireguard, but they go out of their way to kill any potential benefits
# of that; it doesn't/can't integrate with any existing wireguard tooling -- _by design_.
{
  callPackage,
  lib,
  makeBinaryWrapper,
  stdenvNoCC,
  tailscale,
}:
let
  iproute2' = callPackage ./tailscale-iproute2 { };
  # tailscale package wraps binaries with `--prefix PATH ${iproute2}/bin`.
  # tailscale takes 1m to compile, 5m to run tests => slow to iterate.
  # instead, remove iproute2 from tailscale,
  # then re-wrap the binaries with my custom iproute2, separately.
  tailscaleNoIproute2 = tailscale.override {
    iproute2 = null;
    makeWrapper = makeBinaryWrapper;  #< only BinaryWrapper handles `--inherit-argv0` correctly
  };
in stdenvNoCC.mkDerivation {
  inherit (tailscaleNoIproute2) pname version;
  nativeBuildInputs = [
    makeBinaryWrapper  #< only BinaryWrapper handles `--inherit-argv0` correctly
  ];
  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out

    mkdir -p $out/lib/systemd/system
    substitute ${tailscaleNoIproute2}/lib/systemd/system/tailscaled.service $out/lib/systemd/system/tailscaled.service \
      --replace-fail ${tailscaleNoIproute2} $out
    ln -s ${tailscaleNoIproute2}/share $out/share

    mkdir -p $out/bin
    ln -s ${tailscaleNoIproute2}/bin/get-authkey $out/bin/get-authkey
    ln -s tailscaled $out/bin/tailscale
    ln -s ${tailscaleNoIproute2}/bin/tailscaled $out/bin/tailscaled

    wrapProgram $out/bin/tailscaled \
      --inherit-argv0 \
      --prefix PATH : ${lib.makeBinPath [ iproute2' ]}
  '';

  inherit (tailscaleNoIproute2) meta;
  passthru = tailscaleNoIproute2.passthru // {
    iproute2 = iproute2';
  };
}
