{ lib, pkgs, ... }:

/* Helper to debug the Shadow app */
rec {
  /* Wrap the renderer to capture debug logs

    Example:
    wrapRenderer "preprod"
    => (string)
  */
  wrapRenderer = channel: ''
    mv $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/Shadow \
      $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/.Shadow-Orig

    echo "#!${pkgs.runtimeShell}" > $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/Shadow

    echo "echo \"\$@\" > /tmp/shadow.current_cmd" >> \
      $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/Shadow

    echo "strace $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/.Shadow-Orig \"\$@\" > /tmp/shadow.strace 2>&1" >> \
      $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/Shadow

    chmod +x $out/opt/shadow-${channel}/resources/app.asar.unpacked/release/native/Shadow
  '';
}
