{ stdenv, fetchfromgh, unzip }:
let
  pname = "fx";
  version = "18.0.1";

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix = {
    x86_64-linux = "linux";
    x86_64-darwin = "macos";
  }.${system} or throwSystem;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchfromgh {
    inherit version;
    owner = "antonmedv";
    repo = "fx";
    name = "fx-${suffix}.zip";
    sha256 = {
      x86_64-linux = "1q46qidyg6jmk1f74rp2yaqqpg8yzzrw2vmpm2djyiszsqsakfbz";
      x86_64-darwin = "1mcclxn6hw1b8z47kdp26kybk03b59llfgamp425nni0mi5vzrm0";
    }.${system} or throwSystem;
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  unpackPhase = "${unzip}/bin/unzip $src";

  installPhase = "install -Dm755 fx-${suffix} $out/bin/fx";

  postFixup = stdenv.lib.optionalString stdenv.isLinux ''
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "${stdenv.lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      $out/bin/fx
  '';

  meta = with stdenv.lib; {
    description = "Command-line tool and terminal JSON viewer";
    homepage = "https://github.com/antonmedv/fx";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    skip.ci = true;
  };
}
