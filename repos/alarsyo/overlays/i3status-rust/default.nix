final: prev: {
  # overlay created because nixpkgs's `i3status-rust` depended on `notmuch`, and
  # `notmuch`'s tests were briefly broken. the features I'm disabling, I don't
  # need anyway: (at the time of writing)
  #
  # - notmuch
  # - maildir
  i3status-rust = prev.i3status-rust.overrideAttrs (oldAttrs: {
    buildInputs = builtins.attrValues {
      inherit
        (final)
        dbus
        lm_sensors
        openssl
        pulseaudio
        ;
    };
    cargoBuildFeatures = ["pulseaudio"];
  });
}
