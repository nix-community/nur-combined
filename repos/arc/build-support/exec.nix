{ self, super, ... }: with self; {
  writeShellScriptBin = name: contents:
    lib.drvExec "bin/${name}" (super.writeShellScriptBin name contents);
  writeShellScript = name: contents:
    lib.drvExec "" (super.writeShellScript name contents);
}
