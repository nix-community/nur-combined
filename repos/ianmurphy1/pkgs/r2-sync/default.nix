{
  stdenv,
  rclone,
  coreutils,
  makeWrapper,
  lib,
}:
let
  runtimeDeps = [
    rclone
    coreutils
  ];
in
stdenv.mkDerivation {
  pname = "r2-sync";
  version = "0.0.1";
  src = ./.;
  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    install -D -m 0755 script.sh $out/bin/r2-sync

    wrapProgram $out/bin/r2-sync \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';

  meta = {
    description = "Small helper wrapper to upload file to r2";
    homepage = "https://github.com/ianmurphy1/nurpkgs";
    license = lib.licenses.mit;
    mainProgram = "r2-sync";
  };
}
