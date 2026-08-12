{
  lib,
  pkgs,
  stdenv,
  source,
  bashInteractive,
  makeWrapper,
  installShellFiles,
  buildEnv,

  rage,
  age' ? rage,

  git ? null,
  gitSupport ? false,
}:

assert gitSupport -> git != null;

let
  package = stdenv.mkDerivation rec {
    inherit (source) pname src;
    version = "unstable-${source.date}";

    buildInputs = [
      bashInteractive
    ];

    nativeBuildInputs = [
      makeWrapper
      installShellFiles
    ];

    wrapperPath = lib.makeBinPath ([ age' ] ++ lib.optional gitSupport git);

    installPhase = ''
      mkdir -p $out/bin
      cp pa $out/bin/pa
      wrapProgram $out/bin/pa \
        --prefix PATH : "${wrapperPath}"
    '';

    postInstall = ''
      installShellCompletion --cmd pa contrib/pa-completion.{bash,fish}
    '';

    passthru = {
      inherit packages withPackages;
    };

    meta = {
      description = "A simple password manager. encryption via age, written in portable posix shell";
      homepage = "https://github.com/biox/pa";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ vizid ];
      mainProgram = "pa";
      platforms = lib.platforms.linux;
    };
  };
  packages = import ./contrib {
    inherit
      pkgs
      source
      gitSupport
      git
      age'
      ;
    pa = package;
  };
  withPackages =
    f:
    buildEnv {
      name = "pa-env";
      paths = [ package ] ++ f packages;
    };
in
package
