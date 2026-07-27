{ stdenv }:

stdenv.mkDerivation {
  name = "bekind";
  src = ./.;
  phases = [ "installPhase" "fixupPhase" ];
  installPhase = ''
    mkdir -p $out $out/bin $out/share/bekind
    sed "s%profile_dir=\"./profiles\"%profile_dir=$out/share/bekind/profiles%g" $src/bekind > $out/bin/bekind
    chmod +x $out/bin/bekind
    cp -r $src/profiles $out/share/bekind/
  '';
}
