{
  upstream,
  sources,
  source ? sources.opencode,
}:
upstream.opencode.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) version src;
    node_modules = prevAttrs.node_modules.overrideAttrs (
      subFinalAttrs: subPrevAttrs: {
        inherit (finalAttrs) version src;
        outputHash = "sha256-Ws/XERjxQSK8HIDrE/8608TB5gBe4qoFE9mmssry78Y=";
      }
    );

  }
)
