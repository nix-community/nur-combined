{ autoPatchelfHook, fetchurl, stdenv, unzip }:

stdenv.mkDerivation rec {
  name = "deno-bin-${version}";
  version = "1.0.2";

  src = fetchurl {
    url =
      "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
    sha256 = "0n64hs4svbxa75qxng8h2x92kvq9j1mcwnqyzkas5ch55a1zs1bp";
  };

  nativeBuildInputs = [ autoPatchelfHook unzip ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    install -m755 -D deno $out/bin/deno
  '';

  meta = with stdenv.lib; {
    homepage = "https://deno.land";
    description = "A secure runtime for JavaScript and TypeScript";
    platforms = platforms.linux;
  };
}
