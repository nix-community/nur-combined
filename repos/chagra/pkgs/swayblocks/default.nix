{ stdenv, fetchFromGitHub, erlang, beamPackages, callPackage }:

beamPackages.buildMix rec {
  name = "swayblocks-25-11-2018";
  version = "25-11-2018";

  src = fetchFromGitHub {
    owner = "rei2hu";
    repo = "swayblocks";
    rev = "6aa045d8119d647bca04f0250e3d23c4c0491bc3";
    sha256 = "0qdwv7lagyn3fxq6d8mf7xi2khv2zpyrj0sk1fp55m7w3ahq5kzc";
  };

  poison = callPackage ./poison.nix { };

  buildInputs = [ erlang ];
  beamDeps = [ poison ];

  preBuild = ''
    export HOME=.
    make create
  '';

  buildPhase = ''
    runHook preBuild
    export HEX_OFFLINE=1
    export HEX_HOME=`pwd`
    export MIX_ENV=prod
    MIX_ENV=prod mix escript.build --debug-info --no-deps-check
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    MIXENV=prod
    if [ -d "_build/shared" ]; then
      MIXENV=shared
    fi
    mkdir -p "$out/lib/erlang/lib/${name}-${version}"
    for reldir in src ebin priv include; do
      fd="_build/$MIXENV/lib/${name}/$reldir"
      [ -d "$fd" ] || continue
      cp -Hrt "$out/lib/erlang/lib/${name}-${version}" "$fd" && did something
      success=1
    done
    runHook postInstall
  '';

  postInstall = ''
    mkdir -p "$out/bin"
    cp -r ./swayblocks "$out/bin/"
  '';

  meta = with stdenv.lib; {
    description = "a highly customizable, language agnostic status bar manager for i3 and sway written in elixir";
    homepage = "https://github.com/rei2hu/swayblocks";
    license.free = true;
    platforms = platforms.linux;
  };
}
