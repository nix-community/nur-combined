final: prev: {
  openscenegraph = prev.openscenegraph.override {
    colladaSupport = true;
    opencollada = final.collada-dom;
  };
}
