{ stdenv
, lib
, fetchFromGitHub
, python311
, timewarrior
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "task-timewarrior-hook";
  # renovate: datasource=github-releases depName=aklomp/shrinkpdf extractVersion=^shrinkpdf-(?<version>.+)$
  version = "7cd9121ae2eb08de2e5239a93b141144956b9c22";
  src = fetchFromGitHub
  {
    owner = "GothenburgBitFactory";
    repo = name;
    rev = "${version}";
    hash = "sha256-fYTJNoJPdsbqEgXES/tv/FPjAWivsIOp9ZTXdA+4Sd8=";
  };

  preferLocalBuild = true;


  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    python311
    timewarrior
  ];

  installPhase = ''
    df=$out/bin/on-modify.timewarrior
    install -Dm755 $src/on_modify.py "$df"-wrapped
    makeWrapper "$df"-wrapped "$df" \
      --suffix PATH : ${lib.makeBinPath [ timewarrior ]}
  '';

  meta = with lib; {
    description = "Timewarrior on-modify Hook for Taskwarrior";
    homepage = "https://github.com/GothenburgBitFactory/task-timewarrior-hook";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
