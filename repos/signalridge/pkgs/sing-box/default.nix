# sing-box built from source with the patches under ./patches applied to its
# vendored dependencies. Patching the vendored copy (rather than a
# `go mod edit -replace`) keeps the module set, and so vendorHash, identical to
# upstream's: bumping a patch never needs a new hash, bumping sing-box does.
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

let
  version = "1.14.4";
in
buildGoModule {
  pname = "sing-box";
  inherit version;

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v${version}";
    hash = "sha256-1tP0gXUTLGVR32c11nypsZSx2FtBOmKMTJkt+7j/fJU=";
  };

  vendorHash = "sha256-xZWWzvyTrbaxqHG1UdKOVLOd5dPf9z6JfPJf3WeTm5Y=";

  subPackages = [ "cmd/sing-box" ];

  # release/DEFAULT_BUILD_TAGS of the tag, minus with_naive_outbound: that one
  # needs cgo and the prebuilt Cronet libraries, and naive is not used here.
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
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
    "badlinkname"
    "tfogo_checklinkname0"
  ];

  env.CGO_ENABLED = 0;

  # Makefile PARAMS plus release/LDFLAGS of the tag.
  ldflags = [
    "-X github.com/sagernet/sing-box/constant.Version=${version}"
    "-X runtime.godebugDefault=multipathtcp=0,tlssha1=1"
    "-checklinkname=0"
    "-s"
    "-w"
    "-buildid="
  ];

  # buildGoModule runs preBuild in the vendoring derivation too, before vendor/
  # exists; keep the vendored modules upstream's and patch only the build.
  overrideModAttrs = _: { preBuild = ""; };

  # patches/<module path>/*.patch applies, in name order, with -p1 inside
  # vendor/<module path>. `go mod vendor` leaves out _test.go files and
  # testdata, so a patch must not touch them.
  preBuild = ''
    patchRoot=${./patches}
    find "$patchRoot" -name '*.patch' | sort | while read -r p; do
      mod="$(dirname "''${p#"$patchRoot"/}")"
      echo "applying ''${p#"$patchRoot"/}"
      chmod -R u+w "vendor/$mod"
      patch -p1 --forward --no-backup-if-mismatch -d "vendor/$mod" < "$p"
    done
  '';

  # Upstream's tests need network and root; the patched module is tested in
  # its own checkout (see README).
  doCheck = false;

  meta = {
    description = "sing-box with local dependency patches";
    homepage = "https://github.com/SagerNet/sing-box";
    license = lib.licenses.gpl3Plus;
    mainProgram = "sing-box";
  };
}
