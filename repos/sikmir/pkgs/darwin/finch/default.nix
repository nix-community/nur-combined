{ lib, stdenv, buildGoModule, fetchFromGitHub, fetchurl }:

let
  arch = lib.head (lib.splitString "-" stdenv.hostPlatform.system);
  # Check LIMA_URL in Makefile
  lima = {
    "x86_64-darwin" = fetchurl {
      url = "https://deps.runfinch.com/${lib.replaceStrings [ "_" ] [ "-" ] arch}/lima-and-qemu.macos-${arch}.1695247723.tar.gz";
      hash = "sha256-AuyO6Egz5MMFqSE31hNM0VgLXMUBLifpDz4BwclD5LM=";
    };
    "aarch64-darwin" = fetchurl {
      url = "https://deps.runfinch.com/${lib.replaceStrings [ "_" ] [ "-" ] arch}/lima-and-qemu.macos-${arch}.1695247723.tar.gz";
      hash = "sha256-VetbhEPBUiMVdHN6ypS9SJMhHIShVjuurnffPtukzjE=";
    };
  }.${stdenv.hostPlatform.system};
  # Check FINCH_OS_BASENAME in Makefile
  os = {
    "x86_64-darwin" = fetchurl {
      url = "https://dl.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/${arch}/images/Fedora-Cloud-Base-38-1.6.${arch}.qcow2";
      hash = "sha256-0zRnBAH/PVtBKfzGYs9k9ablaCKK9ZB2zESaSUUxhII=";
    };
    "aarch64-darwin" = fetchurl {
      url = "https://dl.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/${arch}/images/Fedora-Cloud-Base-38-1.6.${arch}.qcow2";
      hash = "sha256-0zRnBAH/PVtBKfzGYs9k9ablaCKK9ZB2zESaSUUxhII=";
    };
  }.${stdenv.hostPlatform.system};
in
buildGoModule rec {
  pname = "finch";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "runfinch";
    repo = "finch";
    rev = "v${version}";
    hash = "sha256-vCucOIbePR7WkQR7xr71wyvYgLQgAinH2YxK+YzP/8c=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-GjTsS0VSjWTlopLQa8LfL+P5z1qrliWXKXn2i2c2UHo=";

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
