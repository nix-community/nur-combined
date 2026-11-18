{
  fetchpatch,
  zellij-unwrapped,
}:

zellij-unwrapped.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      # https://github.com/zellij-org/zellij/pull/5375 (not yet merged).
      # Match forwarded terminal replies to their query to avoid attach-time cross-talk.
      url = "https://github.com/zellij-org/zellij/compare/2d26af65939d33908ae04b748caf95a10a6aed3a...cefd251ea19397b7c6681fea94f5f000acc519b1.diff";
      # Keep the runtime fix; the integration harness targets upstream main.
      excludes = [
        "zellij-client/src/stdin_ansi_parser_tests.rs"
        "zellij-integration-tests/src/runner.rs"
        "zellij-integration-tests/tests/startup_host_query.rs"
      ];
      hash = "sha256-CWzJx9LEbzUzbI+LndfASNaWxDSTSz4GCzH7cW2yy/4=";
    })
  ];
})
