{ fetchgit
, lib
, makeWrapper
, stdenv

  # Dependencies
, perl
, ploticus
}:

let
  inherit (lib) escapeShellArg licenses makeBinPath;
in
stdenv.mkDerivation {
  pname = "easy-timeline";
  version = "1.90-unstable-2024-08-02";
  meta = {
    description = "Generate graphical timelines from a simple script";
    homepage = "https://web.archive.org/web/20251008184342/http://infodisiac.com/Wikipedia/EasyTimeline/Introduction.htm";
    downloadPage = "https://phabricator.wikimedia.org/project/profile/140/";
    license = licenses.gpl2Only;
    mainProgram = "easy-timeline";
  };

  src = fetchgit {
    url = "https://gerrit.wikimedia.org/r/mediawiki/extensions/timeline";
    rev = "d515b3103181694f80042b0763753f7ad54b5f8e";
    rootDir = "scripts";
    hash = "sha256-DXH4bZ768EhjNQOK8FolIKP41ILdBOlTb23SJDAR68k=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ perl ];

  installPhase = ''
    install -D --mode 755 'EasyTimeline.pl' "$out/bin/easy-timeline"
    wrapProgram "$out/bin/easy-timeline" \
      --prefix PATH : ${makeBinPath [ ploticus ]} \
      --prefix PERL5LIB : "$PERL5LIB"
  '';

  doInstallCheck = true;
  installCheckPhase =
    let
      test-timeline = ''
        ImageSize = width:128 height:auto barincrement:20
        PlotArea = top:0 right:0 bottom:0 left:0
        TimeAxis = orientation:horizontal
        DateFormat = yyyy
        Period = from:1900 till:2000
        PlotData =
          bar:a
            from:1900 till:1925
          bar:b
            from:1925 till:1950
          bar:c
            from:1950 till:1975
          bar:d
            from:1975 till:2000
      '';
    in
    ''
      echo ${escapeShellArg test-timeline} > 'test-timeline.txt'
      $out/bin/easy-timeline -i 'test-timeline.txt'
      [[ ! -e 'test-timeline.err' ]]
      [[ -f 'test-timeline.png' ]]
      [[ -f 'test-timeline.svg' ]]
    '';
}
