{
config,
lib,
pkgs,
...
}:
let
    inherit (lib) mkIf mkOption types;
    cfg = config.programs.mangohud;

    settingsType =
	with types;
	(oneOf [
	    bool
	    int
	    float
	    str
	    path
	    (listOf (oneOf [
		int
		str
	    ]))
	]);

    renderOption =
	option:
	rec {
	    int = toString option;
	    float = int;
	    path = int;
	    bool = "0"; # "on/off" opts are disabled with `=0`
	    string = option;
	    list = lib.concatStringsSep "," (lib.lists.forEach option (x: toString x));
	}
	.${builtins.typeOf option};

    renderLine = k: v: (if lib.isBool v && v then k else "${k}=${renderOption v}");
    renderSettings =
	attrs: lib.strings.concatStringsSep "\n" (lib.attrsets.mapAttrsToList renderLine attrs) + "\n";

in
    {

    options.programs.mangohud = {
	enable = lib.mkEnableOption "mangohud";

	user = mkOption {
	    type = lib.types.str;
	    default = null;
	    description = "user name";
	    example = "michael";
	};
	home = mkOption {
	    type = lib.types.str;
	    default = null;
	    description = "user home";
	    example = "/home/michael";
	};

	settings = mkOption {
	    type = with types; attrsOf settingsType;
	    default = { };
	    example = lib.literalExpression ''
	{
	  output_folder = ~/Documents/mangohud/;
	  full = true;
	}
	    '';
	    description = ''
	Configuration written to
	{file}`/etc/MangoHud/MangoHud.conf`. See
	<https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf>
	for the default configuration.
	    '';
	};
    };

    config = mkIf cfg.enable {

	environment.systemPackages = [ pkgs.mangohud ];
	programs.steam.extraPackages = [ pkgs.mangohud ];

	programs.steam.gamescopeSession.env.MANGOHUD = "1";
	programs.gamescope.env.MANGOHUD = "1";

	systemd.tmpfiles.rules = [
	    "d ${cfg.home}/.config/MangoHud 0755 ${cfg.user} ${cfg.user} -"
	    "f ${cfg.home}/.config/MangoHud/MangoHud.conf 0755 ${cfg.user} ${cfg.user} -"
	];

	systemd.services.populateMangoHudConf = {
	    description = "Create MangoHud config folder and file";
	    wantedBy = [ "multi-user.target" ];
	    after = [ "systemd-tmpfiles-setup.service" ];
	    script = ''
	echo "${renderSettings cfg.settings}" > ${cfg.home}/.config/MangoHud/MangoHud.conf
	'';
	    serviceConfig = {
		Type = "oneshot";
		User = cfg.user;
		Group = cfg.user;
	    };
	};
    };
}
