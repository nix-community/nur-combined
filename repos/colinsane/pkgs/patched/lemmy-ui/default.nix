{ lemmy-ui, nodejs }:
lemmy-ui.override {
  # build w/ latest nodejs; not 14.x
  inherit nodejs;
}
