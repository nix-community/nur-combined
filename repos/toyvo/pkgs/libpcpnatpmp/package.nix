{
  cmake,
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "libpcpnatpmp";
  version = "20250416";

  src = fetchFromGitHub {
    owner = "libpcpnatpmp";
    repo = "libpcpnatpmp";
    rev = "b5fe5e2ab680eb2359fad31d86ffc29671195bb8";
    sha256 = "sha256-hwo0rlzCRVR8qHxssmN374lGXYFTL18CbJVD8zUROzk=";
  };

  configurePhase = ''
    ${cmake}/bin/cmake -B build
  '';

  buildPhase = ''
    ${cmake}/bin/cmake --build build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/cli-client/pcpnatpmpc $out/bin/
  '';

  meta = with lib; {
    description = "PCP/NAT-PMP client library";
    homepage = "https://github.com/libpcpnatpmp/libpcpnatpmp";
    license = licenses.bsd2;
    maintainers = [
      {
        name = "Collin Diekvoss";
        email = "Collin@Diekvoss.com";
        matrix = "@toyvo:matrix.org";
        github = "ToyVo";
        githubId = 5168912;
      }
    ];
    mainProgram = "pcpnatpmpc";
    platforms = platforms.all;
  };
}
