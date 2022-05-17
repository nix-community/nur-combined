{ ... }: {

  programs.feh.enable = true;

  xdg.mimeApps.associations.added = {
    "image/jpeg;image/png;" = "feh.desktop";
  };
}
