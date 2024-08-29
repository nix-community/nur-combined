{ stdenv
, lib
, fetchFromGitHub
, bash
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "bmc";
  version = "314dc793d7ee9acaf658f2c8623f7ad091193aac";
  src = fetchFromGitHub {
    owner = "wearetechnative";
    repo = "bmc";
    rev = "${version}";
    hash = "sha256-a7Uq+/u95mo3iIO4oqVWr+EF//QX6JLw7Y97q2Z/uJM=";
  };
  buildInputs = [ bash ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp profsel.sh $out/bin/profsel.sh
    wrapProgram $out/bin/profsel.sh \
      --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';
}
