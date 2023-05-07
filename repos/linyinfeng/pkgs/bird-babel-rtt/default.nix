{ sources, bird, autoreconfHook }:

bird.overrideAttrs (old: {
  inherit (sources.bird-babel-rtt) version src;
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    autoreconfHook
  ];
})
