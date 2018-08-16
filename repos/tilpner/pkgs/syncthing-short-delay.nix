{ syncthing }:

syncthing.overrideAttrs (old: {
  patchPhase = ''
    substituteInPlace \
      lib/watchaggregator/aggregator.go \
      --replace 'shortDelayMultiplicator := 6' 'shortDelayMultiplicator := 1'
  '';
})
