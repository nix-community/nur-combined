{
  lib,
  buildGoModule,
  fetchurl,
}:
buildGoModule rec {
  pname = "systemd-lock-handler";
  version = "2.4.0";

  # NOTE: Niv can't handle generic git HTTP/S URLs that don't end in ".git",
  # and sr.ht doesn't support appending ".git" to repo URLs
  src = fetchurl {
    url = "https://git.sr.ht/~whynothugo/systemd-lock-handler/archive/v2.4.0.tar.gz";
    sha256 = "12m3paz1h3npymy4yvzwkfqw6hl34g6y39i4shxvnkjb1db35bqd";
  };

  vendorHash = "sha256-dWzojV3tDA5lLdpAQNC9NaADGyvV7dNOS3x8mfgNNtA=";

  patches = [
    ./start-unit-stuck.patch
  ];

  postPatch = ''
    substituteInPlace systemd-lock-handler.service \
      --replace /usr/lib/ $out/lib/
  '';

  installPhase = ''
    runHook preInstall

    # Make expects to find the binary here
    cp $GOPATH/bin/${pname} ./

    make ''${makeFlags[@]} install

    runHook postInstall
  '';

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = with lib; {
    description = "Translates systemd-system lock/sleep signals into systemd-user target activations";
    homepage = "https://git.sr.ht/~whynothugo/systemd-lock-handler";
    maintainers = with maintainers; [ arobyn ];
    platforms = with platforms; linux;
    license = licenses.isc;
  };
}
