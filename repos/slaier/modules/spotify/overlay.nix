final: prev: {
  spotifywm = prev.spotifywm.overrideAttrs (self: {
    propagatedBuildInputs = [ ];
    installPhase = ''
      install -Dm644 spotifywm.so $out/lib/spotifywm.so
    '';
  });

  spotify = final.symlinkJoin {
    name = "spotify";
    paths = [ prev.spotify ];
    buildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
        --prefix LD_PRELOAD : "${final.spotifywm}/lib/spotifywm.so"
    '';
  };
}
