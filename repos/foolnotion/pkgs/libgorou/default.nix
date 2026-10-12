{ stdenv
, lib
, pugixml
, libzip
, curl
, openssl
, updfparser
, fetchgit
}:
let
  updfparser_ = updfparser.overrideAttrs(old: {
    src = fetchgit {
      url = "https://forge.soutade.fr/soutade/uPDFParser.git";
      rev = "6060d123441a06df699eb275ae5ffdd50409b8f3";
      hash = "sha256-HD73WGZ4e/3T7vQmwU/lRADtvsInFG62uqvJmF773Rk=";
    };
  });
in
stdenv.mkDerivation rec {
  pname = "libgorou";
  version = "0.8.6";

  buildInputs = [ curl pugixml libzip openssl updfparser_ ];

  src = builtins.fetchGit {
    url = "https://forge.soutade.fr/soutade/libgourou.git";
    #rev = "0d77cf55e1b0de1e8238d12c1e4015863135485d";
    ref = "refs/tags/v0.8.6";
    submodules = true;
  };

  makeFlags = [ "BUILD_STATIC=1" "BUILD_SHARED=1" ];

  buildPhase = ''
    mkdir lib
    cp -r ${updfparser_}/lib lib/updfparser
    mkdir obj
    make build_utils
  '';

  installPhase = ''
    make install PREFIX=$out LIBDIR=/lib INCDIR=/include
  '';

  meta = with lib; {
    description = "Eovim is the Enlightened Neovim (EFL Gui client for Neovim).";
    license = licenses.mit;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ xxx ];
  };
}
