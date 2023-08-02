# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
(next: prev: {
  pipewire = prev.pipewire.override {
    # avoid a dep on python3.10-PyQt5, which has mixed qt5 versions.
    # this means we lose firewire support (oh well..?)
    ffadoSupport = false;
  };
})
