{ stdenv, fetchurl, unzip, python2 }:

stdenv.mkDerivation rec {
  version = "0.30c";
  name = "endgame-singularity-${version}";

  srcs =
    [
      (fetchurl {
        url = "http://www.emhsoft.com/singularity/singularity-${version}-src.tar.gz";
        sha256 = "13zjhf67gmla67nkfpxb01rxs8j9n4hs0s4n9lnnq4zgb709yxgl";
      })
      (fetchurl {
        url = "http://www.emhsoft.com/singularity/endgame-singularity-music-007.zip";
        sha256 = "0vf2qaf66jh56728pq1zbnw50yckjz6pf6c6qw6dl7vk60kkqnpb";
      })
    ];
  sourceRoot = ".";

  buildInputs = [ unzip ];
  propagatedBuildInputs = [ (python2.withPackages (ps: with ps; [ pygame numpy ])) ];

  buildPhase = ''
    python2 -m compileall singularity-${version}
    python2 -O -m compileall singularity-${version}
  '';

  installPhase = ''
    install -Dm644 singularity-${version}/singularity.py $out/share/singularity.py
    cp -R singularity-${version}/code singularity-${version}/data $out/share/
    cp -R endgame-singularity-music-007 $out/share/music
    echo "cd $out/share; ${python2.withPackages (ps: with ps; [ pygame numpy ])}/bin/python2 $out/share/singularity.py '$@'" > endgame-singularity
    install -Dm755 endgame-singularity $out/bin/endgame-singularity
  '';

  meta = {
    homepage = "http://www.emhsoft.com/singularity/";
    description = "A simulation of a true AI. Go from computer to computer, pursued by the entire world. Keep hidden, and you might have a chance";
    license = stdenv.lib.licenses.gpl2;
    maintainers = with stdenv.lib.maintainers; [ fgaz ];
  };
}
