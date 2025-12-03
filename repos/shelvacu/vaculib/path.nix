{ ... }:
{
  path = arg: if builtins.isPath arg then builtins.path { path = arg; } else builtins.path arg;
}
