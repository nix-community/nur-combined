{ stdenv, rustPlatform, fetchFromGitHub
, xorg, libGL, portmidi
}:

with rustPlatform;

let
  rpathLibs = [
    xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr libGL portmidi
  ];
in
  buildRustPackage rec {
    name = "31key-${version}";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "diaschisma";
      repo = "31key";
      rev = "6c7648d428294488756dbc27d148bff7265842a2";
      sha256 = "1rhhmjijz5k930j73vwiqkbpxvmpmn62zdqhljj5ak187pnx5rmh";
    };

    buildInputs = rpathLibs;

    installPhase = ''
      runHook preInstall

      install -D target/release/31key $out/bin/31key
      patchelf --set-rpath "${stdenv.lib.makeLibraryPath rpathLibs}" $out/bin/31key

      runHook postInstall
    '';

    doCheck = false;
    dontPatchELF = true;

    cargoSha256 = "1wwak4n6hb021f9s8pcq3qb81lz29r957296fcx3vl2kbn0kl3mc";

    meta = with stdenv.lib; {
      broken = true;
      description = "Tricesimoprimal Keyboard";
      homepage = https://github.com/diaschisma/31key;
      license = [ licenses.mit ];
      maintainers = [ ];
      platforms = platforms.all;
    };
  }
