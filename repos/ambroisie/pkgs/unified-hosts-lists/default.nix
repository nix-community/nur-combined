{ lib, fetchFromGitHub, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "unified-hosts-lists";
  version = "3.11.16";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-YB/3v6qMz/iERRV/AvbOMoLgtqHdXarCrZApfUqzwmo=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp -r $src/hosts $out
    for file in $src/alternates/*/hosts; do
        cp $file $out/$(basename $(dirname $file))
    done
  '';

  meta = with lib; {
    description = "Unified host lists";
    longDescription = ''
      Consolidating and extending hosts files from several well-curated sources.
      Optionally pick extensions for porn, social media, and other categories.
    '';
    homepage = "https://github.com/StevenBlack/hosts";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ambroisie ];
  };
}
