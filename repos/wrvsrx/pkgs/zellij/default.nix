{
  fetchpatch,
  zellij,
  zellij-unwrapped,
}:

zellij.override {
  zellij-unwrapped = zellij-unwrapped.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        url = "https://github.com/zellij-org/zellij/compare/b0bd3e1e7f530db8879e8cbde79de245e6101a8a...b1ba929bf0ec284478ce21948bd8cb52aac7631d.diff";
        # The PR targets a newer main; its test context does not apply to 0.45.0.
        excludes = [
          "zellij-client/src/stdin_ansi_parser_tests.rs"
          "zellij-integration-tests/tests/startup_host_query.rs"
        ];
        hash = "sha256-4j17Sv7YnzQVpe1VkiBQHiyCzpw+E5bnkPAO4HZglxs=";
      })
    ];
  });
}
