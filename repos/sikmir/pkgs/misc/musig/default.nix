{ lib, buildGoModule, pkg-config, portaudio, sources }:

buildGoModule rec {
  pname = "musig-unstable";
  version = lib.substring 0 10 sources.musig.date;

  src = sources.musig;

  vendorSha256 = "0ha1xjdwibm8543b4bx0xrbigngiiakksdc6mnp0mz5y6ai56pg5";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ portaudio ];

  buildFlagsArray = [ "-ldflags=-X main.VERSION=${version}" ];

  doInstallCheck = true;

  installCheckPhase = "$out/bin/musig --version";

  meta = with lib; {
    inherit (sources.musig) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
