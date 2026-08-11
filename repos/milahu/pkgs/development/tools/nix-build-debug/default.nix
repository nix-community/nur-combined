{ lib
, stdenv
, fetchFromGitHub
, bashInteractive
, gawk
, jq
}:

let
  # use a patched version of bash
  # disable job control in the debug shell
  # with this, Ctrl-Z will stop the debug shell
  # and return to the parent shell
  # see also nixpkgs/pkgs/shells/bash/5.nix
  bash-without-jobcontrol = bashInteractive.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ [
      "--disable-job-control"
    ];
  });
in

stdenv.mkDerivation rec {
  pname = "nix-build-debug";
  version = "unstable-2024-05-06";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "nix-build-debug";
    rev = "ce5eea8743f75f16c11e7dc4b571a41cafe51564";
    hash = "sha256-JwEvPunLlSP+SpYrlty/6RAMdhoh73ocgQ16P2PQtqU=";
  };

  passthru = {
    inherit bash-without-jobcontrol;
  };

  # note: ''' -> ''
  buildPhase = ''
    substituteInPlace nix-build-debug.sh \
      --replace-fail \
        "bash_without_jobcontrol='''" \
        "bash_without_jobcontrol='${bash-without-jobcontrol}/bin/bash'" \
      --replace-fail \
        'extra_path=""' \
        "extra_path='${gawk}/bin:${jq}/bin'" \
  '';

  installPhase = ''
    mkdir -p $out/opt
    cd ..
    cp -r $sourceRoot $out/opt/nix-build-debug

    mkdir -p $out/bin
    ln -sr $out/opt/nix-build-debug/nix-build-debug.sh $out/bin/nix-build-debug
  '';

  meta = with lib; {
    description = "Debug failing nix-build in interactive bash shell";
    homepage = "https://github.com/milahu/nix-build-debug";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "nix-build-debug";
    platforms = platforms.all;
  };
}
