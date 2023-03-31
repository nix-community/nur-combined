{ lib, stdenv, buildGoModule, fetchFromGitHub, fetchurl }:

let
  arch = lib.head (lib.splitString "-" stdenv.hostPlatform.system);
  # Check LIMA_URL in Makefile
  lima = {
    "x86_64-darwin" = fetchurl {
      url = "https://deps.runfinch.com/${lib.replaceStrings [ "_" ] [ "-" ] arch}/lima-and-qemu.macos-${arch}.1679936560.tar.gz";
      hash = "sha256-WpDR71QwMVi5ztJ0t+2lv3nPdpsrrAZunBNgSUtHags=";
    };
    "aarch64-darwin" = fetchurl {
      url = "https://deps.runfinch.com/${lib.replaceStrings [ "_" ] [ "-" ] arch}/lima-and-qemu.macos-${arch}.1679936560.tar.gz";
      hash = "sha256-WpDR71QwMVi5ztJ0t+2lv3nPdpsrrAZunBNgSUtHags=";
    };
  }.${stdenv.hostPlatform.system};
  # Check FINCH_OS_BASENAME in Makefile
  os = {
    "x86_64-darwin" = fetchurl {
      url = "https://dl.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/${arch}/images/Fedora-Cloud-Base-37-1.7.${arch}.qcow2";
      hash = "sha256-tbm+yR7uZUiaV0X27mIFc7IzN8ux60UBziALFXoB86A=";
    };
    "aarch64-darwin" = fetchurl {
      url = "https://dl.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/${arch}/images/Fedora-Cloud-Base-37-1.7.${arch}.qcow2";
      hash = "sha256-zIsPSbxgh1oW7vZa0T4OhrpQK6NYXMURRvEfQYKmKMA=";
    };
  }.${stdenv.hostPlatform.system};
in
buildGoModule rec {
  pname = "finch";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    rev = "v${version}";
    hash = "sha256-xzYFb75qcHZ7Zb8SenrnVCGolitPneg6B/ejtPAe1uI=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-/jfYIXLeM8ddUrHJyihK2agM6AmSO9lEWWz4YTGbIvg=";

  subPackages = [ "cmd/finch" ];

  ldflags = [
    "-X github.com/runfinch/finch/pkg/version.Version=${version}"
  ];

  doCheck = false;

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    mkdir -p $out/Applications/Finch/{bin,lima,os}
    mv $out/bin/finch $out/Applications/Finch/bin
    ln -s $out/Applications/Finch/bin/finch $out/bin/finch

    tar -xvf ${lima} -C $out/Applications/Finch/lima
    cp ${os} $out/Applications/Finch/os/${os.name}

    cp config.yaml $out/Applications/Finch
    cp finch.yaml $out/Applications/Finch/os

    substituteInPlace $out/Applications/Finch/os/finch.yaml \
      --replace "<finch_image_location>" "$out/Applications/Finch/os/${os.name}" \
      --replace "<finch_image_arch>" "${arch}" \
      --replace "<finch_image_digest>" "sha256:$(sha256sum ${os} | cut -d' ' -f1)"
  '';

  meta = with lib; {
    description = "Client for container development";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.darwin;
    skip.ci = true;
  };
}
