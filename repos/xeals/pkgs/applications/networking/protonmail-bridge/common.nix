{ lib
, fetchFromGitHub
, buildGoModule
, pkg-config
, libsecret
}:

{ pname
, tags
, ...
}@args:

buildGoModule (lib.recursiveUpdate args rec {
  inherit pname;
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "ProtonMail";
    repo = "proton-bridge";
    rev = "br-${version}";
    sha256 = "1na8min9cmn82lpad58abw6837k303fr09l6cvzswaxs73f231ig";
  };

  vendorSha256 = "1219xa1347877bfhnid15y6w9s4hf1czbrmll2iha4gpsmg066bb";

  nativeBuildInputs = (args.nativeBuildInputs or [ ]) ++ [
    pkg-config
  ];

  buildInputs = (args.buildInputs or [ ]) ++ [
    libsecret
  ];

  buildFlagsArray =
    let
      t = "github.com/ProtonMail/proton-bridge/pkg/constants";
    in
    [
      "-tags=${tags}"
      ''
        -ldflags=
          -X ${t}.Version=${version}
          -X ${t}.Revision=unknown
          -X ${t}.BuildDate=unknown
      ''
    ];

  meta = with lib; {
    description = "Integrate ProtonMail paid account with any program that supports IMAP and SMTP";
    homepage = "https://protonmail.com";
    license = licenses.gpl3;
    plaforms = platforms.x86_64;
  };
})
