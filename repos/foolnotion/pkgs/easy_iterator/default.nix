{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "EasyIterator";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "TheLartians";
    repo = "EasyIterator";
    rev = "f3f89399ba8bca617040c1503f4f9fe3582a6abd";
    sha256 = "";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DEVE_BUILD_TEST=OFF" "-DEVE_BUILD_BENCHMARKS=OFF" "-DEVE_BUILD_DOCUMENTATION=OFF" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Zero cost abstractions for designing and using C++ iterators";
    homepage = "https://github.com/TheLartians/EasyIterator";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
