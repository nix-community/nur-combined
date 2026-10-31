{
  gobject-introspection,
  fetchFromGitHub,
  buildGoModule,
  gdk-pixbuf,
  pkg-config,
  fetchgit,
  fetchurl,
  graphene,
  pango,
  cairo,
  glib,
  gtk4,
  lib,
}: let
  ringbuf = fetchFromGitHub {
    owner = "noisetorch";
    repo = "c-ringbuf";
    rev = "2037560fb90dea5d2538611d983964d790bdbac2";
    hash = "sha256-LWX85C1nbUDqOolWDixn91YKsARNTVzO3PoYF7auw84=";
  };

  rnnoise = fetchgit {
    url = "https://git.serversmp.xyz/Mirrors/rnnoise.git";
    rev = "70f1d256acd4b34a572f999a05c87bf00b67730d";
    hash = "sha256-fkSy7Sqnx0yLfGLciHf8PaptzFVzFAeRrhE4R5z8hSw=";
  };

  rnnoiseModel = fetchurl {
    url = "https://media.xiph.org/rnnoise/models/rnnoise_data-0a8755f8e2d834eff6a54714ecc7d75f9932e845df35f8b59bc52a7cfe6e8b37.tar.gz";
    hash = "sha256-CodV+OLYNO/2pUcU7MfXX5ky6EXfNfi1m8UqfP5uizc=";
  };
in
  buildGoModule (finalAttrs: {
    pname = "noisetorch-next";
    version = "0bd8ba1664cf53564c497d8faa52388e86a49467";

    src = fetchFromGitHub {
      owner = "ForkPrince";
      repo = "NoiseTorch";
      rev = finalAttrs.version;
      hash = "sha256-gNvY15Do6QlXNBkWyjfY+6X1b8LmdWRAyM5CxstLZ4w=";
    };

    vendorHash = null;
    doCheck = false;

    nativeBuildInputs = [pkg-config];

    buildInputs = [
      gobject-introspection
      gdk-pixbuf
      graphene
      pango
      cairo
      glib
      gtk4
    ];

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${finalAttrs.version}"
      "-X main.distribution=nixpkgs"
    ];

    preBuild = ''
      mkdir -p c/c-ringbuf c/rnnoise

      cp -r ${ringbuf}/. c/c-ringbuf/
      cp -r ${rnnoise}/. c/rnnoise/

      chmod -R u+w c

      tar xzf ${rnnoiseModel} -C c/rnnoise

      make -C c/ladspa/
      go generate

      rm ./scripts/*
    '';

    postInstall = ''
      install -Dm444 assets/icon/noisetorch.png $out/share/icons/hicolor/256x256/apps/noisetorch.png
      install -Dm444 assets/noisetorch.desktop $out/share/applications/noisetorch.desktop
    '';

    meta = {
      description = "Virtual microphone device with noise suppression for PulseAudio (ForkPrince next fork)";
      homepage = "https://github.com/ForkPrince/NoiseTorch";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
      maintainers = with lib.maintainers; [Prinky panaeon];
      mainProgram = "noisetorch";
    };
  })
