{ stdenv, fetchFromGitLab, python3, bash, sxiv}:

stdenv.mkDerivation {
  name = "rank_photos";
  version = "2.0.0";
  
  src = fetchFromGitLab {
    domain = "git.dodsorf.as";
    owner = "dandellion";
    repo = "elo-rank-photos";
    rev = "e7b3f8d4ee7069aba9622a1651d15834ddb060b5";
    sha256 = "1y8wgvcsv5avg1vggwkn8n53kklj7qwnqbxa8gkn9zzfymddvwq9";
  };

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      matplotlib
      tkinter
      numpy
      exifread
      pillow
    ]))
    bash
    sxiv
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./rank_photos.py $out/bin/rank_photos
    cp ./view_ranked.sh $out/bin/view_ranked
    chmod +x $out/bin/rank_photos $out/bin/view_ranked
  '';
  
  meta = {
    description = "Compare and rank images by select which one is best and assigning elo ranking.";
  };

}
