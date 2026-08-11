{
  lib,
  buildGoModule,
  fetchFromGitHub,
  fuse,
  makeWrapper,
}:

buildGoModule rec {
  pname = "distribyted";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "distribyted";
    repo = "distribyted";
    rev = "v${version}";
    hash = "sha256-XOvznIAKYVO0rVzkEj85CVALNiYJY5W0Z4ZC1ALF/qI=";
  };

  vendorHash = "sha256-CXCRchksH6PhO9LPGCQwtNBaxs39uTW639G362Bw75s=";

  ldflags = [ "-s" "-w" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    fuse
  ];

  postInstall = ''
    # fix: panic: cgofuse: cannot find FUSE
    wrapProgram $out/bin/distribyted \
      --prefix LD_LIBRARY_PATH : ${fuse.out}/lib
  '';

  # fix: checkPhase hangs
  doCheck = false;

  meta = {
    description = "Torrent client with HTTP, fuse, and WebDAV interfaces";
    homepage = "https://github.com/distribyted/distribyted";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "distribyted";
  };
}
