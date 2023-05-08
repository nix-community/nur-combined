{ ... }:

{
  # libreoffice: disable first-run stuff
  sane.programs.libreoffice-fresh.fs.".config/libreoffice/4/user/registrymodifications.xcu".symlink.text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="FirstRun" oor:op="fuse"><value>false</value></prop></item>
      <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="ShowTipOfTheDay" oor:op="fuse"><value>false</value></prop></item>
    </oor:items>
  '';
  # <item oor:path="/org.openoffice.Setup/Product"><prop oor:name="LastTimeDonateShown" oor:op="fuse"><value>1667693880</value></prop></item>
  # <item oor:path="/org.openoffice.Setup/Product"><prop oor:name="LastTimeGetInvolvedShown" oor:op="fuse"><value>1667693880</value></prop></item>
}
