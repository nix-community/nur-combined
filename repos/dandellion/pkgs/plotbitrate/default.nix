{ stdenv, fetchFromGitHub, python3, ffmpeg}:

stdenv.mkDerivation {
  name = "plot_bitrate";
  version = "1.0.0";
  
  src = fetchFromGitHub {
    owner = "zeroepoch";
    repo = "plotbitrate";
    rev = "4553220ed5132503c0dda777bcc41b83ec866004";
    sha256 = "1d93nygc9imz576akh2vgvnyb7z6s7xva5s5i8vg1kxa5060an7y";
  };

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      matplotlib
    ]))
    ffmpeg
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./plotbitrate.py $out/bin/plotbitrate
    chmod +x $out/bin/plotbitrate
  '';
  
  meta = {
    description = "plot bitrate in video.";
  };

}
