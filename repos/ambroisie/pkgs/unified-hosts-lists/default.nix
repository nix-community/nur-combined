{ lib, fetchFromGitHub, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "unified-hosts-lists";
  version = "3.8.5";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "sha256-7oYuGegrHVUvAvA16iR8OEe5eTMeSybShSa1PJOe5No=";
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
