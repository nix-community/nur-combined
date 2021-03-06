{ stdenv, fetchFromGitHub, rustPlatform, openssl, pkg-config, steam-run-native, lib }:

rustPlatform.buildRustPackage rec {
  pname = "shticker_book_unwritten";
  version = "1.0.3";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = "1lcz96fixa0m39y64cjkf2ipzv4qxf000hji3mf536scr3wsxdib";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  postInstall = ''
    mv -v $out/bin/shticker_book_unwritten $out/bin/.shticker_book_unwritten-wrapped

    cat > $out/bin/shticker_book_unwritten << EOF
    #!${stdenv.shell} -e
    exec ${steam-run-native}/bin/steam-run $out/bin/.shticker_book_unwritten-wrapped "\$@"
    EOF
    chmod a+x $out/bin/shticker_book_unwritten
  '';

  meta = {
    description = "Minimal CLI launcher for the Toontown Rewritten MMORPG";
    homepage = "https://github.com/JonathanHelianthicusDoe/shticker_book_unwritten";
    license = stdenv.lib.licenses.gpl3Plus;
  };
}
