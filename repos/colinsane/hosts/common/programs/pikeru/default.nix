{ ... }:
{
  sane.programs.pikeru = {
    sandbox.method = null;  #< TODO: sandbox

    services.pikeru = {
      description = "pikeru (xdg-desktop-portal FileChooser backend)";
      dependencyOf = [ "xdg-desktop-portal" ];
      command = "pikeru";
      readiness.waitDbus = "org.freedesktop.impl.portal.desktop.pikeru";
    };
  };
}


