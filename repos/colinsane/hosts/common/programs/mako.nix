# config docs:
# - `man 5 mako`
{ ... }:
{
  sane.programs.mako = {
    fs.".config/mako/config".symlink.text = ''
      # notification interaction mapping
      # "on-touch" defaults to "dismiss", which isn't nice for touchscreens.
      on-button-left=invoke-default-action
      on-touch=invoke-default-action
      on-button-middle=dismiss-group

      max-visible=3
      # notifications can be grouped by:
      # - app-name
      # - app-icon
      # - summary
      # - body
      # possibly more: urgency, category, desktop-entry, ...
      # to group by multiple fields, join with `,`
      group-by=app-name

      # BELOW IS SXMO DEFAULTS, modified very slightly.
      # TODO: apply theme colors!

      # default-timeout=15000
      background-color=#ffffff
      text-color=#000000
      border-color=#000000
      layer=overlay
      # group-by=app-name

      [urgency=low]
      # default-timeout=10000
      background-color=#222222
      text-color=#888888

      [urgency=high]
      default-timeout=0
      background-color=#900000
      text-color=#ffffff
      background-color=#ff0000
    '';
  };
}
