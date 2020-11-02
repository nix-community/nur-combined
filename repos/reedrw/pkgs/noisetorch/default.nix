{ stdenv, buildGoModule, fetchFromGitHub, rnnoise-plugin }:

buildGoModule rec {
  pname = "NoiseTorch";
  version = "0.7.3-beta";

  src = fetchFromGitHub {
    owner = "lawl";
    repo = "NoiseTorch";
    rev = version;
    sha256 = "15fmz31kji6qhf8vg0gd790m18q7m9rz7gwqmp7fyp6rcmgn5lq4";
  };

  patches = [ ./version.patch ./config.patch ./embedlibrnnoise.patch ];

  vendorSha256 = null;

  doCheck = false;

  subPackages = [ "." ];

  buildInputs = [ rnnoise-plugin ];

  preBuild = ''
    export RNNOISE_LADSPA_PLUGIN="${rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
    go generate;
    rm  ./scripts/*
  '';

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps/
    cp assets/icon/noisetorch.png $out/share/icons/hicolor/256x256/apps/
    mkdir -p $out/share/applications/
    cp assets/noisetorch.desktop $out/share/applications/
  '';

  meta = with stdenv.lib; {
    description = "Virtual microphone device with noise supression for PulseAudio";
    homepage = "https://github.com/lawl/NoiseTorch";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ panaeon ];
  };
}
