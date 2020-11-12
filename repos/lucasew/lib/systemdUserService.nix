# TODO: what happens if a enabled unit fails at boot?
{
  description,
  command,
  enable ? true
}:
{
  Unit = {
    Description = description;
  };
  Service = {
    Type = "exec";
    ExecStart = command;
    Restart = "on-failure";
  };
  Install = {
    WantedBy = if enable then [
      "default.target"
    ] else [];
  };
}
