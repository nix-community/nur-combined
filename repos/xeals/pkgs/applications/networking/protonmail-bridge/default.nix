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
      version = "1.4.5";

      src = fetchFromGitHub {
        owner = "ProtonMail";
        repo = "proton-bridge";
        rev = "br-${version}";
        sha256 = "1339h3sa7xhqx7mbq2zzvv3mln0zsxh4aa437hs4r3gbq8jvbf97";
      };

      vendorSha256 = "0kdjm30xchng09k09fr7mfs9abgl0xncc25v9hzqfli6ii1qr1l2";

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
