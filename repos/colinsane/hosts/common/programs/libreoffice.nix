{ pkgs, ... }:

{
  sane.programs.libreoffice = {
    # variants: "still" (stable?), "fresh" (beta?)
    # packageUnwrapped = pkgs.libreoffice-bin;
    # packageUnwrapped = pkgs.libreoffice-still;
    packageUnwrapped = pkgs.libreoffice-fresh;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingFile";
    sandbox.extraHomePaths = [
      # allow a spot to save files.
      # with bwrap sandboxing, saving to e.g. ~/ succeeds but the data is inaccessible outside the sandbox,
      # easy to shoot yourself in the foot!
      "tmp"
    ];

    buildCost = 3;

    # disable first-run stuff
    fs.".config/libreoffice/4/user/registrymodifications.xcu".symlink.text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="FirstRun" oor:op="fuse"><value>false</value></prop></item>
        <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="ShowTipOfTheDay" oor:op="fuse"><value>false</value></prop></item>
      </oor:items>
    '';
    # <item oor:path="/org.openoffice.Setup/Product"><prop oor:name="LastTimeDonateShown" oor:op="fuse"><value>1667693880</value></prop></item>
    # <item oor:path="/org.openoffice.Setup/Product"><prop oor:name="LastTimeGetInvolvedShown" oor:op="fuse"><value>1667693880</value></prop></item>
  };
}
