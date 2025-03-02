{
  sources,
  callPackage,
  buildVimPlugin,
}:
final: prev: {
  coc-zk = callPackage ./coc-zk {
    source = sources.coc-zk;
  };
  coc-markdown = callPackage ./coc-markdown {
    source = sources.coc-markdown;
  };
}
