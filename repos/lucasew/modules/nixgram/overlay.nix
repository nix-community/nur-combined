self: super:
{
  nixgram = super.callPackage ./package.nix {};
  mkNixgramCommand = name: command: super.mkShellScriptBin ("nixgram-" + name) command;
}
