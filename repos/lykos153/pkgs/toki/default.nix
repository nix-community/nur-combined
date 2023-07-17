{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, timewarrior
, jq
}:

stdenv.mkDerivation rec {
  name = "toki";
  # renovate: datasource=github-releases depName=aklomp/shrinkpdf extractVersion=^shrinkpdf-(?<version>.+)$
  version = "1.0.3";
  src = fetchFromGitHub
  {
    owner = "cheap-glitch";
    repo = name;
    rev = "v${version}";
    hash = "sha256-xt6dh0qgtBSUA9F2EZbcX8ReBd8mrpGiBImsmHQhLVo=";
  };

  preferLocalBuild = true;

  unpackPhase = "true";
  configurePhase = "true";
  buildPhase = "true";

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    for sf in "$src"/src/toki*; do
      df="$out/bin/.$(basename "$sf")-wrapped"
      wrapper="$out/bin/$(basename "$sf")"
      install -Dm755 "$sf" "$df"
      makeWrapper "$df" "$wrapper" \
        --suffix PATH : ${lib.makeBinPath [ timewarrior jq ]}
    done
  '';

  meta = with lib; {
    description = "A Bash wrapper around the Timewarrior CLI that aims to improve its usability.";
    homepage = https://github.com/cheap-glitch/toki;
    license = licenses.isc;
    platforms = platforms.all;
  };
}
