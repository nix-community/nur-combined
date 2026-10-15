{
  lib,
  stdenv,
  python3,
  makeWrapper,
  iproute2,
  systemd,
}:

stdenv.mkDerivation {
  pname = "svc-ports";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    install -D -m 755 svc-ports.py $out/bin/svc-ports
    wrapProgram $out/bin/svc-ports \
      --prefix PATH : "${
        lib.makeBinPath [
          iproute2
          systemd
          python3
        ]
      }"
  '';

  meta = with lib; {
    description = "List running systemd services and their listening ports";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "svc-ports";
  };
}
