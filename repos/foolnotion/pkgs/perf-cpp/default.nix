{ lib
, stdenv
, fetchFromGitHub
, cmake
, buildShared ? !stdenv.hostPlatform.isStatic

, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "perf-cpp";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "jmuehlig";
    repo = "perf-cpp";
    rev = "v${version}";
    hash = "sha256-1nkSG5XzoXNuzY9Vm6oitFlVHa8n/dtGEf70v1n7hu8=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ ] ++ lib.optional buildShared "-DBUILD_SHARED_LIBS=ON";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "C++ library to make performance analysis more intuitive and focused";
    homepage = "https://github.com/jmuehlig/perf-cpp";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
