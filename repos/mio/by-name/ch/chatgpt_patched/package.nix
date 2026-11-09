{
  chatgpt,
  codex_patched,
  tectonic_patched,
}:

chatgpt.override {
  codex = codex_patched;
  tectonic-unwrapped = tectonic_patched.passthru.unwrapped;
}
