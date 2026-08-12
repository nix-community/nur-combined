{ stdenv, lib, fetchFromGitHub, rustPlatform
, pkgconfig, pam, libxkbcommon
, wayland, fontconfig
}:

let
  libraryPath = lib.makeLibraryPath [ wayland libxkbcommon ];
in
rustPlatform.buildRustPackage rec {
  pname = "waylock";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "ifreund";
    repo = "waylock";
    rev = "v${version}";
    hash = "sha256-hIu+yzbnmALorkJywqcPY4fiqetarYCX/OPXq3ZKKh4=";
  };

  cargoSha256 = "sha256-GJfNlQ/+nEswZJNfPkvRcRxRO31MZP8q2dQt0LjwExE=";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ pam fontconfig ];

  dontPatchELF = true;

  postInstall = ''
    echo "$(patchelf --print-rpath $out/bin/waylock)"
    patchelf --set-rpath ${libraryPath}:$(patchelf --print-rpath $out/bin/waylock) \
      $out/bin/waylock
  '';

  meta = with lib; {
    description = "A simple screenlocker for Wayland compositors.";
    homepage = "https://github.com/ifreund/waylock";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainer = with maintainers; [ berbiche ];
  };
}
