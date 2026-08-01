{
  "$base" = "rgb(000000)";
  "$text" = "rgb(000000)";
  "$textAlpha" = "000000";
  "$yellow" = "rgb(E5C07B)";
  "$red" = "rgb(E06C75)";
  "$accent" = "rgb(C678DD)";
  "$accentAlpha" = "C678DD";
  "$surface0" = "rgb(FFFFFF)";
  "$borderLight" = "rgb(F4F4F4)";
  "$borderGray" = "rgb(CECECE)";
  "$lightGray" = "rgb(E6E6E6)";
  "$mediumGray" = "rgb(D9D9D9)";

  "$font" = "caskaydia-cove";

  "$ready_message" = "Awaiting authentication method.";
  "$present_message" = "🧬 Analyzing DNA sequence...";
  "$check_message" = "Identifying...";

  background = {
    color = "$base";
  };

  shape = [
    {
      color = "$lightGray";
      size = "40%, 30%";
      border_size = 2;
      border_color = "$borderLight";
      halign = "center";
      valign = "center";
    }
    {
      color = "$mediumGray";
      size = "16%, 26%";
      position = "-11%, 0%";
      border_size = 1;
      border_color = "$borderGray";
      halign = "center";
      valign = "center";
    }
    {
      size = "9%, 2.5%";
      color = "$surface0";
      rounding = 1;
      border_size = 1;
      border_color = "$borderGray";
      position = "14%, 0%";
      halign = "center";
      valign = "center";
      zindex = 1;
    }
  ];

  image = [
    {
      path = "$HOME/repos/dotfiles/media/shared/icons/logos/png/nixos_purple.png";
      size = "18%, 30%";
      rounding = 1;
      position = "-11%, 0%";
      border_size = 0;
      halign = "center";
      valign = "center";
    }
  ];

  input-field = {
    monitor = "";
    size = "9%, 2.5%";
    outline_thickness = 1;
    dots_size = 0.25;
    dots_spacing = 0.2;
    dots_center = false;
    outer_color = "$borderGray";
    inner_color = "$surface0";
    font_color = "$text";
    fade_on_empty = false;
    placeholder_text = "";
    hide_input = false;
    rounding = 1;
    check_color = "$borderGray";
    check_text = ''<span foreground="##$textAlpha">$check_message</span>'';
    fail_color = "$red";
    fail_text = "<i>$PAMFAIL <b>($ATTEMPTS)</b></i>";
    capslock_color = "$yellow";
    position = "14%, -3%";
    halign = "center";
    valign = "center";
    zindex = 1;
  };

  label = [
    {
      text = ''cmd[update:0] echo "<b>$(hyprlock --version)</b>"'';
      color = "$text";
      font_size = 16;
      font_family = "$font";
      position = "10.5%, 10%";
      halign = "center";
      valign = "center";
    }
    {
      text = "$FPRINTPROMPT $FPRINTFAIL";
      color = "$text";
      font_size = 14;
      font_family = "$font";
      position = "10.5%, 5%";
      halign = "center";
      valign = "center";
    }
    {
      text = "<b>Username:</b>";
      color = "$text";
      font_size = 16;
      font_family = "$font";
      position = "6%, 0%";
      halign = "center";
      valign = "center";
      zindex = 1;
    }
    {
      text = "$USER";
      color = "$text";
      font_size = 14;
      font_family = "$font";
      position = "12%, 0%";
      halign = "center";
      valign = "center";
      zindex = 2;
    }
    {
      text = "<b> Password:</b>";
      color = "$text";
      font_size = 16;
      font_family = "$font";
      position = "6%, -3%";
      halign = "center";
      valign = "center";
      zindex = 1;
    }
    {
      text = ''cmd[update:60000] date +"%d-%b-%y (%a); %I:%M %p"'';
      color = "$text";
      font_size = 10;
      font_family = "$font";
      position = "-31.5%, -5.5%";
      halign = "right";
      valign = "center";
    }
    {
      text = "$LAYOUT";
      color = "$text";
      font_size = 10;
      font_family = "$font";
      position = "-31.5%, -7%";
      halign = "right";
      valign = "center";
    }
  ];
}
