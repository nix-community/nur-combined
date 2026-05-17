{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "unordered_dense";
  version = "4.8.1";

  src = fetchFromGitHub {
    owner = "martinus";
    repo = "unordered_dense";
    rev = "v${version}";
    hash = "sha256-JdPlyShWnAcdgixDHRaroFg7YWdPtD4Nl1PmpcQ1SAk=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A fast & densely stored hashmap and hashset based on robin-hood backward shift deletion";
    homepage = "https://github.com/martinus/unordered_dense";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
