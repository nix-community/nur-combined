{ lib
, stdenv
, fetchFromGitHub
, cmake
, patchelf
#, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "stream-unrar";
  version = "unstable-2017-06-13";

  src = fetchFromGitHub {
    owner = "vlovich";
    repo = "stream-unrar";
    rev = "15d59960b5e787ebcd6276362fb5a8c268f8211f";
    hash = "sha256-4xWgM+RPbAqqgK/6RtE4PE+ep59R6zwMZtWzq+vx+VE=";
  };

  nativeBuildInputs = [
    cmake
    patchelf
    #autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp stream-unrar $out/bin

    mkdir -p $out/lib
    cp 3rd_party/unrar*/libunrar.so $out/lib

    # remove reference to /build/source/build/3rd_party/unrar-4.0.7/libunrar.so
    #addAutoPatchelfSearchPath $out/lib
    patchelf $out/bin/stream-unrar \
      --add-rpath $out/lib \
      --allowed-rpath-prefixes /nix/store \
      --shrink-rpath

    runHook postInstall
  '';

  meta = with lib; {
    description = "On-the-fly extraction of rar files being downloaded from a newsgroup, http, etc";
    homepage = "https://github.com/vlovich/stream-unrar";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "stream-unrar";
    platforms = platforms.all;
  };
}
