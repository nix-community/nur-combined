{
  blink-cmp,
  fetchFromGitHub,
}:
blink-cmp.overrideAttrs (oldAttrs: {
  version = "${oldAttrs.version}-unstable-2026-08-10";
  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "blink.cmp";
    rev = "dac4aa1b1816076b6f8efc8cb18312c3fb513369";
    hash = "sha256-AwAVUTYYnABQaBy+ROtZaPF7f3WcD5eUkpYz+GRNeQM=";
  };
})
