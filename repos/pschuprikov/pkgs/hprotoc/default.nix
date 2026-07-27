{ lib, haskell, fetchFromGitHub, protocol-buffers, protocol-buffers-descriptor, hprotoc }:
let
  src = fetchFromGitHub {
    owner = "k-bx";
    repo = "protocol-buffers";
    rev = "9b109f2fefa75f45911edc967db145505bfc7a1b";
    sha256 = "sha256-oiOsAxJ5RLTmavA2v0Pm9bP52JNNj2/0Kn/yiA498EI=";
  };

  new-protocol-buffers = protocol-buffers.overrideAttrs
    (attrs: { inherit src; });
  new-protocol-buffers-descriptor =
    (protocol-buffers-descriptor.overrideAttrs (attrs: {
      inherit src;
      sourceRoot = "source/descriptor";
    })).override { protocol-buffers = new-protocol-buffers; };
in ((haskell.lib.overrideCabal hprotoc (attrs: {
  inherit src;
  editedCabalFile = null;
})).overrideAttrs (attrs: { sourceRoot = "source/hprotoc"; })).override {
  protocol-buffers = new-protocol-buffers;
  protocol-buffers-descriptor = new-protocol-buffers-descriptor;
}
