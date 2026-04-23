{
  debianutils, # run-parts needed at runtime
  fetchbzr,
  lib,
  makeBinaryWrapper,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "update-motd";
  version = "3.7";

  src = fetchbzr {
    url = "https://code.launchpad.net/~kirkland/update-motd/main";
    rev = "94";
    sha256 = "sha256-3qhIN/OX4HgFfahsNeBT6Gw8r4/WwlSdn8JsStdxUVo=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv update-motd $out/bin/

    wrapProgram $out/bin/update-motd \
      --prefix PATH : ${lib.makeBinPath [ debianutils ]}

    mkdir -p $out/share/man/man8/
    mv update-motd.8 $out/share/man/man8/

    mkdir -p $out/share/update-motd
    mv update-motd.sh $out/share/update-motd/

    substituteInPlace $out/share/update-motd/update-motd.sh \
      --replace '/usr/bin/update-motd' "$out/bin/update-motd"

    runHook postInstall
  '';

  meta = {
    description = "Modular framework to dynamically generate the message of the day";
    homepage = "https://launchpad.net/update-motd";
    license = lib.licenses.gpl3;
    mainProgram = "update-motd";
    maintainers = with lib.maintainers; [ wwmoraes ];
    platforms = lib.platforms.all;
  };
}
