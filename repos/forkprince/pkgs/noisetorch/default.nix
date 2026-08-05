{
  fetchFromGitHub,
  buildGoModule,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "NoiseTorch";
  version = "5200d8d0c71d9682256d71b87c3aa625febc08f9";

  src = fetchFromGitHub {
    owner = "ForkPrince";
    repo = "NoiseTorch";
    rev = "5200d8d0c71d9682256d71b87c3aa625febc08f9";
    hash = "sha256-WttsCMO43e+BPIcE4pbnvdC3OI00N4x0KnaMcAHOwbU=";
    fetchSubmodules = true;
  };

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
