{ ... }:
{
	programs.rofi = {
		enable = true;
		theme = "Arc-Dark";
		extraConfig = {
			modi = "run,filebrowser";
			color-normal = "#1c2023, #919ba0, #1c2023, #a4a4a4, #1c2023";
			color-urgent = "argb:00000000, #f43753, argb:00000000, argb:00000000, #e29a49";
			color-active = "argb:00000000, #49bbfb, argb:00000000, argb:00000000, #e29a49";
			color-window = "#1c2023, #919ba0, #1c2023";
		};
	};
}
