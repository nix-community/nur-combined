{ stdenv
, fetchFromGitHub
, lib
, nix-update-script
, pulseaudio
, autoreconfHook
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "pulseaudio-module-xrdp";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "neutrinolabs";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GT0kBfq6KvuiX30B9JzCiUxgSm9E6IhdJuQKKKprDCE=";
  };

  pulseaudioPreprocess = pulseaudio.overrideAttrs (old: {
    pname = "${old.pname}-src";
    installPhase = ''
      cp $NIX_BUILD_TOP $out -rfv
      cp ./* $out -rfv
    '';
    outputs = [ "out" ];
    phases = [ "unpackPhase" "patchPhase" "configurePhase" "installPhase" ];
  });

  preConfigure = ''
    cp -r ${pulseaudioPreprocess}/pulseaudio-* pulseaudio-src
    chmod +w -Rv pulseaudio-src
    cp ${pulseaudioPreprocess}/config.h pulseaudio-src
    chmod +w -Rv pulseaudio-src/config.h

    find ./pulseaudio-src/ -type f | while read file; do
      substituteInPlace "$file" --replace ${pulseaudioPreprocess} ${pulseaudio} || true
    done
    configureFlags="$configureFlags PULSE_DIR=$(realpath ./pulseaudio-src)"
  '';

  installPhase = ''
    mkdir $out/lib/pulseaudio/modules $out/bin $out/etc/xdg/autostart -p
    install -m 755 src/.libs/*.so $out/lib/pulseaudio/modules
    install -m 755 instfiles/load_pa_modules.sh $out/bin/pulseaudio_xrdp_init
    install -m 755 instfiles/pulseaudio-xrdp.desktop.in  $out/etc/xdg/autostart/pulseaudio-xrdp.desktop
    substituteInPlace $out/etc/xdg/autostart/pulseaudio-xrdp.desktop \
      --replace 'Exec=@pkglibexecdir@/load_pa_modules.sh' "Exec=$out/bin/pulseaudio_xrdp_init"
  '';

  nativeBuildInputs = [ pulseaudio.dev autoreconfHook pkg-config ];

  passthru = {
    updateScript = nix-update-script { };
    inherit pulseaudioPreprocess;
  };
}
