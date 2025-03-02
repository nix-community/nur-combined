{ pkgs, nur, ... }:

{
  environment.systemPackages = [
    (pkgs.sbcl.withPackages (ps: [
      (ps.slynk.overrideLispAttrs (
        { systems, ... }:
        {
          systems = systems ++ [
            "slynk/mrepl"
            "slynk/indentation"
            "slynk/stickers"
            "slynk/trace-dialog"
            "slynk/package-fu"
            "slynk/fancy-inspector"
            "slynk/arglists"
            "slynk/profiler"
            "slynk/retro"
          ];
        }
      ))
      # ps.april
      ps.serapeum
    ]))
    nur.repos.nagy.hyperspec
  ];
}
