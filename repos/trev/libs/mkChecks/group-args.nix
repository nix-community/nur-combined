{
  lib,
  message,
}:
{
  script.script = ''
    test ${lib.escapeShellArg message} = hello
  '';
}
