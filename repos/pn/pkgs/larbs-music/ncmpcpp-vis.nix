{ stdenv, ncmpcpp }:

(ncmpcpp.override {
  visualizerSupport = true;
}).overrideAttrs(oldAttrs: {
  meta.description = "ncmpcpp with visualizer support";
})
