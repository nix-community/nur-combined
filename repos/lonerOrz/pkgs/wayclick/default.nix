{
  lib,
  stdenv,
  python3Packages,
  libnotify,
  makeWrapper,
  procps,
  coreutils,
  util-linux,
}:
let
  pythonEnv = python3Packages.python.withPackages (
    ps: with ps; [
      evdev
      pygame-ce
    ]
  );
in
stdenv.mkDerivation {
  pname = "wayclick";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    pythonEnv
    libnotify
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/wayclick

    cp src/wayclick.sh $out/lib/wayclick/wayclick.sh
    cp src/runner.py   $out/lib/wayclick/runner.py

    chmod +x $out/lib/wayclick/wayclick.sh

    makeWrapper \
      $out/lib/wayclick/wayclick.sh \
      $out/bin/wayclick \
      --set WAYCLICK_RUNNER $out/lib/wayclick/runner.py \
      --set PYTHON ${pythonEnv}/bin/python3 \
      --prefix PATH : ${
        lib.makeBinPath [
          procps
          coreutils
          util-linux
          libnotify
        ]
      }
  '';

  meta = {
    description = "Low-latency key click sound engine using evdev + pygame";
    homepage = "https://github.com/dusklinux/dusky";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wayclick";
  };
}
