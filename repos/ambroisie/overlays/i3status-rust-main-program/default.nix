final: prev:
{
  i3status-rust = prev.i3status-rust.overrideAttrs (oa: {
    meta = oa.meta or { } // {
      mainProgram = "i3status-rs";
    };
  });
}
