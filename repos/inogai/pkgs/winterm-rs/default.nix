{
  lib,
  writeShellScriptBin,
}:
writeShellScriptBin "winterm-rs" ''
  echo "ERROR: This package (winterm-rs) is currently broken and cannot be used."
  exit 1
''
// {
  meta = {
    description = "A snowfall animation in your terminal (BROKEN)";
    homepage = "https://github.com/inogai/winterm-rs";
    changelog = "https://github.com/inogai/winterm-rs/releases";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.inogai];
    mainProgram = "winterm-rs";
    platforms = lib.platforms.all;
    broken = true;
  };
}

