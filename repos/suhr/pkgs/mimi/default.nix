{ stdenv, rustPlatform, fetchFromGitHub
, portmidi
}:

with rustPlatform;

let
  rpathLibs = [
    portmidi
  ];
in
  buildRustPackage rec {
    name = "mimi-${version}";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "diaschisma";
      repo = "mimi";
      rev = "6f4f314907172c86e000ca7b59aef441630611ba";
      sha256 = "04r3d5pggm5gnglk09zwq0izz2gn81gb2y7lhdf04iplqhqicia7";
    };

    buildInputs = rpathLibs;

    installPhase = ''
      runHook preInstall

      install -D target/release/mimi $out/bin/mimi
      patchelf --set-rpath "${stdenv.lib.makeLibraryPath rpathLibs}" $out/bin/mimi

      runHook postInstall
    '';

    doCheck = false;
    dontPatchELF = true;

    cargoSha256 = "1ii3j1y7akc0mhgdb63rvpxhd1apsi6b6isymbl073m4ssz7qg9x";

    meta = with stdenv.lib; {
      description = "Tricesimoprimal Keyboard";
      homepage = https://github.com/diaschisma/mimi;
      license = [ licenses.mit ];
      maintainers = [ ];
      platforms = platforms.all;
    };
  }
