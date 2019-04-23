{ stdenv, rustPlatform, fetchFromGitHub
, libxcb
, pkgconfig, python3
}:

rustPlatform.buildRustPackage rec {
  pname = "xcolor";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "Soft";
    repo = "xcolor";
    rev = "${version}";
    sha256 = "1nxyy0d12xw1pksshxl31h2fzcaqazlw60g1h279jh103b2xdbhz";
  };

  cargoSha256 = "0wm89q9i0qb32c21jfvcrp3d58685npdzqpvdi16h92hsnz42pzy";

  outputs = [ "bin" "man" "out" ];

  nativeBuildInputs = [ pkgconfig python3 ];
  buildInputs = [ libxcb ];

  postPatch = let makefileSedScript = ''
    /^install:/{s#target/release/[^ ]\+##g};
    #install .* -- target/release/\([^ ]\+\) ".*bin/\1"$#{d}
  ''; in ''
    # don't make install binaries or libraries
    sed -i ${stdenv.lib.escapeShellArg makefileSedScript} Makefile
  '';

  makeFlags = [ "PREFIX=$(bin)" ];

  postInstall = ''
    # fix buildRustPackage installPhase locations
    moveToOutput bin "''${!outputBin}"
    moveToOutput lib "''${!outputLib}"

    # Old bash empty array hack
    # shellcheck disable=SC2086
    local flagsArray=(
        $makeFlags ''${makeFlagsArray+"''${makeFlagsArray[@]}"}
        $installFlags ''${installFlagsArray+"''${installFlagsArray[@]}"}
        ''${installTargets:-install}
    )

    echoCmd 'install flags' "''${flagsArray[@]}"
    make ''${makefile:+-f $makefile} "''${flagsArray[@]}"
    unset flagsArray
  '';

  meta = with stdenv.lib; {
    description = "Lightweight color picker for X11";
    longDescription = ''
      Lightweight color picker for X11. Use your mouse to select colors
      visible anywhere on the screen to get their RGB representation.
    '';
    homepage = https://soft.github.io/xcolor;
    license = with licenses; mit;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
  };
}
