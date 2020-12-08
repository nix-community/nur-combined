{ stdenv
, fetchFromGitHub
, buildGoModule

, go
, goModules
, libsecret
, pkg-config
, qtbase
, qtdoc
}:

let

  builder =
    { pname
    , tags
    , ...
    }@args:

    buildGoModule (stdenv.lib.recursiveUpdate args rec {
      inherit pname;
      version = "1.5.2";

      src = fetchFromGitHub {
        owner = "ProtonMail";
        repo = "proton-bridge";
        rev = "br-${version}";
        sha256 = "1mv7fwapcarii43nnsgk7ifqlah07k54zk6vxxxmrp04gy0mzki6";
      };

      vendorSha256 = "01d6by8xj9py72lpfns08zqnsym98v8imb7d6hgmnzp4hfqzbz3c";

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

      meta = with stdenv.lib; {
        description = "Integrate ProtonMail paid account with any program that supports IMAP and SMTP";
        homepage = "https://protonmail.com";
        license = licenses.gpl3;
        plaforms = platforms.x86_64;
      };
    });

in

{
  protonmail-bridge = builder (import ./app.nix { inherit qtbase go goModules; });
  protonmail-bridge-headless = builder (import ./headless.nix { });
}
