{
  gsettings-desktop-schemas,
  gobject-introspection,
  hicolor-icon-theme,
  adwaita-icon-theme,
  fetchFromGitHub,
  wrapGAppsHook4,
  buildGoModule,
  gdk-pixbuf,
  pkg-config,
  graphene,
  dconf,
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

  rnnoise = fetchFromGitHub {
    owner = "noisetorch";
    repo = "rnnoise";
    rev = "1cbdbcf1283499bbb2230a6b0f126eb9b236defd";
    hash = "sha256-i+dTZrxgecKrLz4d96Qy+pzARb1ZvTCISm4hv+v7Gfg=";
  };
in
  buildGoModule (finalAttrs: {
    pname = "noisetorch-next";
    version = "16710a6db9cfd149f89977d46ad2c63f949f33c6";

    src = fetchFromGitHub {
      owner = "ForkPrince";
      repo = "NoiseTorch";
      rev = finalAttrs.version;
      hash = "sha256-tPlM3+PW6j6pwur/Hk9bL92MRzldUPlY48maDH8CkO4=";
    };

    vendorHash = null;
    doCheck = false;

    nativeBuildInputs = [
      wrapGAppsHook4
      pkg-config
    ];

    buildInputs = [
      gsettings-desktop-schemas
      gobject-introspection
      adwaita-icon-theme
      hicolor-icon-theme
      gdk-pixbuf
      graphene
      dconf
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

      make -C c/ladspa/
      go generate

      rm ./scripts/*
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : "${adwaita-icon-theme}/share"
        --prefix XDG_DATA_DIRS : "${hicolor-icon-theme}/share"
      )
    '';

    postInstall = ''
      install -Dm444 assets/icon/noisetorch.png $out/share/icons/hicolor/256x256/apps/io.github.noisetorch.NoiseTorch.png
      install -Dm444 assets/noisetorch.desktop $out/share/applications/io.github.noisetorch.NoiseTorch.desktop

      substituteInPlace $out/share/applications/io.github.noisetorch.NoiseTorch.desktop \
        --replace-fail "Icon=noisetorch" "Icon=io.github.noisetorch.NoiseTorch"
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
