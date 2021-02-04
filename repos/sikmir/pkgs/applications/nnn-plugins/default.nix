{ lib, stdenv, sources }:

stdenv.mkDerivation {
  pname = "nnn-plugins";
  version = lib.substring 0 10 sources.nnn.date;

  src = sources.nnn;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    cd $src/plugins
    for f in $(find . -maxdepth 1 \( ! -iname "." ! -iname "*.md" \)); do
      install -Dm755 "$f" -t $out/share/nnn/plugins
    done
  '';

  meta = with lib; {
    description = "Plugins extend the capabilities of nnn";
    homepage = "https://github.com/jarun/nnn/tree/master/plugins";
    license = licenses.bsd2;
    platforms = platforms.all;
    maintainers = [ maintainers.sikmir ];
    skip.ci = true;
  };
}
