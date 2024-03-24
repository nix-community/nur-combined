# docs are via README only:
# - <https://github.com/phuhl/linux_notification_center>
# reload config:
# - `notify-send a --hint=boolean:deadd-notification-center:true --hint=string:type:reloadStyle`
# toggle visibility:
# - `kill -s USR1 $(pidof deadd-notification-center)`
# clear notifications:
# - `notify-send a --hint=boolean:deadd-notification-center:true --hint=string:type:clearInCenter`
# set state of user button 0 to "highlighted" (true)
# - `notify-send a --hint=boolean:deadd-notification-center:true --hint=int:id:0 --hint=boolean:state:true --hint=type:string:buttons`
{ ... }:
{
  sane.programs.deadd-notification-center = {
    fs.".config/deadd/deadd.css".symlink.target = ./deadd.css;
    fs.".config/deadd/deadd.yml".symlink.target = ./deadd.yml;
  };
}
