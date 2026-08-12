{
  fetchFromGitHub,
  buildGoModule,
  lib,
}:
let
  mainRev = "5200d8d0c71d9682256d71b87c3aa625febc08f9";

  mainSrc = fetchFromGitHub {
    owner = "ForkPrince";
    repo = "NoiseTorch";
    rev = mainRev;
    hash = "sha256-D5us2S/2+aqBTsom+e/lTd5Xg1Vw01XOI0d9YUmEC1M=";
    fetchSubmodules = false;
  };

  ringbufSrc = fetchFromGitHub {
    owner = "noisetorch";
    repo = "c-ringbuf";
    rev = "2037560fb90dea5d2538611d983964d790bdbac2";
    hash = "sha256-LWX85C1nbUDqOolWDixn91YKsARNTVzO3PoYF7auw84=";
    fetchSubmodules = false;
  };

  rnnoiseSrc = fetchFromGitHub {
    owner = "noisetorch";
    repo = "rnnoise";
    rev = "1cbdbcf1283499bbb2230a6b0f126eb9b236defd";
    hash = "sha256-i+dTZrxgecKrLz4d96Qy+pzARb1ZvTCISm4hv+v7Gfg=";
    fetchSubmodules = false;
  };
in
buildGoModule (finalAttrs: {
  pname = "NoiseTorch";
  version = mainRev;

  src = mainSrc;

  vendorHash = null;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.distribution=nixpkgs"
  ];

  subPackages = [ "." ];

  preBuild = ''
    mkdir -p c
    cp -r "${ringbufSrc}/." c/c-ringbuf/
    cp -r "${rnnoiseSrc}/." c/rnnoise/
    chmod -R u+w c/c-ringbuf c/rnnoise
    make -C c/ladspa/
    go generate
    rm  ./scripts/*
  '';

  postInstall = ''
    install -D ./assets/icon/noisetorch.png $out/share/icons/hicolor/256x256/apps/noisetorch.png
    install -Dm444 ./assets/noisetorch.desktop $out/share/applications/noisetorch.desktop
  '';

  meta = {
    description = "Virtual microphone device with noise supression for PulseAudio (ForkPrince fork)";
    homepage = "https://github.com/ForkPrince/NoiseTorch";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      Prinky
      panaeon
    ];
    mainProgram = "noisetorch";
  };
})
