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
      version = "1.3.2";

      src = fetchFromGitHub {
        owner = "ProtonMail";
        repo = "proton-bridge";
        rev = "v${version}";
        sha256 = "05nj8hxr7ay0r2r46k1pxjb96swzkd67k1n0kz9203sjgax5y6bw";
      };

      vendorSha256 = "14grhpxld9ajg28b0zwc39kwmikxqy9pm42nfdc04g6fmaxvi5c9";

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
