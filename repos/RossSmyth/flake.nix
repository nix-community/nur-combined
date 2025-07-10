{
  outputs = _: {
    overlays.default = final: _: final.callPackage ./. { };
  };
}
