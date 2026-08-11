{ lib
, buildGoModule
, fetchFromGitHub
, xorg
, libxkbcommon
, libpng
}:

buildGoModule rec {
  pname = "buster-client";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "dessant";
    repo = "buster-client";
    rev = "v${version}";
    hash = "sha256-tayM4fhxLd52h0ZElumdSCHRWCdOUSqoS7kyzEhVdq8=";
  };

  # fix: vendor/github.com/robotn/gohook/hook.go:22:10: fatal error: event/goEvent.h: No such file or directory
  proxyVendor = true;

  vendorHash = "sha256-nw9mRoQzCy2z9xiW0djy7JOWCcyjIXFQAuW/YqQrSDE=";

  modRoot = "cmd/client";

  ldflags = [
    "-s"
    "-w"
    "-X=main.name=${pname}"
    "-X=main.version=${version}"
    "-X=main.buildVersion=${version}"
    "-X=main.commit=${src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  buildInputs = [
    xorg.xorgproto
    xorg.libX11
    xorg.libXtst
    xorg.libXi
    libxkbcommon
    libpng
  ];

  # the buster-client is not usable from the command line
  # so dont install it to $out/bin
  # buster-client-setup installs the binary to
  # ~/.local/opt/buster/buster-client

  binPath = "opt/buster/buster-client";

  postInstall = ''
    mkdir -p $(dirname $out/${binPath})
    mv $out/bin/client $out/${binPath}
    rmdir $out/bin
  '';

  meta = with lib; {
    description = "User input simulation for Buster";
    homepage = "https://github.com/dessant/buster-client";
    changelog = "https://github.com/dessant/buster-client/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "buster-client";
    platforms = platforms.all;
  };
}
