{ ... }:

{
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
  };
}
