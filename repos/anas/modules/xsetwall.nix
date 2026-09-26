{ config, lib, options, pkgs, ... }:

let
  cfg = config.services.xsetwall;

  optionalArg = flag: value:
    lib.optionals (value != null && value != "") [
      flag
      value
    ];

  strOrEmpty = value: if value == null then "" else value;

  # NixOS and Home Manager expose incompatible schemas for `systemd.user.services`:
  # NixOS uses named options (`script`, `wantedBy`, `path`, ...) while Home Manager
  # uses raw systemd sections (`Unit`, `Service`, `Install`).
  isHomeManager = options.systemd.user.services.type.getSubOptions [ ] ? Unit;
  useHomeManager = cfg.unitStyle == "home-manager"
    || (cfg.unitStyle == "auto" && isHomeManager);

  # The xsetwall options that are applied in every mode, without the image
  globalArgs = lib.concatLists [
    (lib.optional cfg.whiteBorder "-w")
    (optionalArg "-s" cfg.scale)
    (lib.optional cfg.alignLeft "-l")
    (lib.optional cfg.alignRight "-r")
    (lib.optional cfg.alignTop "-t")
    (lib.optional cfg.alignBottom "-b")
    cfg.extraArgs
  ];

  cycling = cfg.mode != "static";

  # Picks a wallpaper for the current mode and hands it to xsetwall, retrying
  # with another image until `tries` attempts are used up.
  setWallpaper = pkgs.writeShellScriptBin "xsetwall-pick" (lib.removeSuffix "\n" ''
    set -euo pipefail
    export LC_ALL=C

    xsetwall=${lib.escapeShellArg (lib.getExe cfg.package)}
    xsetwall_args=(${lib.concatMapStringsSep " " lib.escapeShellArg globalArgs})
    extensions=(${lib.concatMapStringsSep " " lib.escapeShellArg cfg.extensions})
    mode=${lib.escapeShellArg cfg.mode}
    directory=${lib.escapeShellArg (strOrEmpty cfg.directory)}
    static_wallpaper=${lib.escapeShellArg (strOrEmpty cfg.staticWallpaper)}
    avoid_repeat=${if cfg.avoidRepeat then "true" else "false"}
    tries=${toString cfg.tries}

    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/xsetwall"

    list_images() {
      local dir=$1 ext image
      shopt -s nocaseglob
      for ext in "''${extensions[@]}"; do
        for image in "$dir"/*."$ext"; do
          [ -f "$image" ] && printf '%s\n' "$image"
        done
      done
      shopt -u nocaseglob
    }

    pick_image() {
      local dir=$1
      local -a images=() pool=()
      local image next=""

      mapfile -t images < <(list_images "$dir" | ${pkgs.coreutils}/bin/sort)
      [ "''${#images[@]}" -gt 0 ] || return 1

      if [ "$mode" = random ]; then
        # A retry never offers an image an earlier attempt already failed on.
        local -a exclude=("''${tried[@]}")
        if [ "$avoid_repeat" = true ] && [ -r "$state_dir/current" ]; then
          exclude+=("$(<"$state_dir/current")")
        fi

        for image in "''${images[@]}"; do
          local skip=false seen
          for seen in "''${exclude[@]}"; do
            if [ "$image" = "$seen" ]; then
              skip=true
              break
            fi
          done
          [ "$skip" = true ] || pool+=("$image")
        done

        [ "''${#pool[@]}" -gt 0 ] || pool=("''${images[@]}")
        printf '%s\n' "''${pool[RANDOM % ''${#pool[@]}]}"
        return 0
      fi

      if [ -r "$state_dir/current" ]; then
        local last
        last=$(<"$state_dir/current")
        for image in "''${images[@]}"; do
          if [[ "$image" > "$last" ]]; then
            next=$image
            break
          fi
        done
      fi

      printf '%s\n' "''${next:-''${images[0]}}"
    }

    image=""
    status=0
    attempt=1
    tried=()

    while [ "$attempt" -le "$tries" ]; do
      image=""

      if [ "$mode" = static ]; then
        image=$static_wallpaper
      else
        image=$(pick_image "$directory") || image=""
        if [ -z "$image" ]; then
          echo "xsetwall: no images found in $directory, using the static wallpaper" >&2
          image=$static_wallpaper
        fi
        ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
        printf '%s\n' "$image" >"$state_dir/current"
      fi

      if [ -z "$image" ]; then
        echo "xsetwall: no wallpaper to set" >&2
        exit 1
      fi

      echo "xsetwall: attempt $attempt of $tries, setting $image"
      status=0
      "$xsetwall" "''${xsetwall_args[@]}" "$image" || status=$?

      if [ "$status" -eq 0 ]; then
        break
      fi

      echo "xsetwall: failed to set $image, xsetwall exited with $status" >&2
      tried+=("$image")
      attempt=$((attempt + 1))
    done

    if [ "$status" -ne 0 ]; then
      echo "xsetwall: giving up after $tries attempts, last exit status $status" >&2
    fi

    exit $status
  '');

  serviceUnit =
    if useHomeManager then {
      Unit = {
        Description = "Set the X11 wallpaper with xsetwall";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${setWallpaper}/bin/xsetwall-pick";
      } // lib.optionalAttrs (cfg.display != "") {
        Environment = [ "DISPLAY=${cfg.display}" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];
    } else {
      description = "Set the X11 wallpaper with xsetwall";

      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      environment = lib.optionalAttrs (cfg.display != "") { DISPLAY = cfg.display; };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${setWallpaper}/bin/xsetwall-pick";
      };
    };

  timerUnit =
    if useHomeManager then {
      Unit.Description = "Rotate the X11 wallpaper with xsetwall";

      Timer = {
        OnUnitActiveSec = "${toString cfg.interval}s";
        AccuracySec = "1s";
      };

      Install.WantedBy = [ "timers.target" ];
    } else {
      description = "Rotate the X11 wallpaper with xsetwall";

      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnUnitActiveSec = "${toString cfg.interval}s";
        AccuracySec = "1s";
        Unit = "xsetwall.service";
      };
    };
in
{
  options.services.xsetwall = {
    enable = lib.mkEnableOption "xsetwall";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.xsetwall;
      description = "The xsetwall package to use.";
    };

    display = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        The X11 display to set the wallpaper on, exported as `DISPLAY` to the
        service. Empty means to inherit the display of the user session.
      '';
    };

    unitStyle = lib.mkOption {
      type = lib.types.enum [ "auto" "nixos" "home-manager" ];
      default = "auto";
      description = ''
        The systemd user unit schema to emit. NixOS and Home Manager declare
        incompatible options for `systemd.user.services`, so `"auto"` picks
        the one matching the system the module is evaluated on. Only change
        this if the detection picks the wrong schema for your system.
      '';
    };

    whiteBorder = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Fill the unused area around the image with white.";
    };

    scale = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "0.5";
      description = ''
        A custom image scale factor, as a positive floating point number.
        The image is scaled to fit the screen when unset.
      '';
    };

    alignLeft = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Align the image to the left side of the screen.";
    };

    alignRight = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Align the image to the right side of the screen.";
    };

    alignTop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Align the image to the top of the screen.";
    };

    alignBottom = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Align the image to the bottom of the screen.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--foo" ];
      description = ''
        Extra xsetwall arguments, passed before the image argument.
      '';
    };

    # Image selection.
    mode = lib.mkOption {
      type = lib.types.enum [ "static" "alphabetical" "random" ];
      default = "static";
      description = ''
        How the wallpaper is chosen.

        - `"static"` always sets {option}`services.xsetwall.staticWallpaper`.
        - `"alphabetical"` cycles through the images in
          {option}`services.xsetwall.directory`, sorted by file name.
        - `"random"` picks a random image from
          {option}`services.xsetwall.directory` on every change.
      '';
    };

    staticWallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/user/Pictures/wallpapers/static.png";
      description = ''
        The image to set in the `"static"` mode, and the fallback for the
        other modes when {option}`services.xsetwall.directory` holds no
        matching image.
      '';
    };

    directory = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/user/Pictures/wallpapers";
      description = ''
        The directory holding the wallpapers to pick from. Only used by the
        `"alphabetical"` and `"random"` modes.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3600;
      description = ''
        The time in seconds between two wallpaper changes. Only used by the
        `"alphabetical"` and `"random"` modes.
      '';
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "jpg"
        "jpeg"
        "png"
      ];
      description = ''
        The file extensions to look for in
        {option}`services.xsetwall.directory`. The defaults are the image
        formats xsetwall understands.
      '';
    };

    avoidRepeat = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to avoid picking the same image twice in a row in the
        `"random"` mode.
      '';
    };

    tries = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3;
      description = ''
        The number of times to try setting a wallpaper before giving up.
        Every failed attempt is logged with the image it tried, and the next
        attempt uses a different image: the `"alphabetical"` mode moves on to
        the following image, and the `"random"` mode avoids the images the
        earlier attempts already failed on. The `"static"` mode has no other
        image to fall back on, so it retries the same one. The exit status of
        the last attempt becomes the exit status of the service.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.mode == "static" || (cfg.directory != null && cfg.directory != "");
        message = "services.xsetwall.directory must be set when services.xsetwall.mode is \"${cfg.mode}\".";
      }
      {
        assertion = cfg.mode != "static" || (cfg.staticWallpaper != null && cfg.staticWallpaper != "");
        message = "services.xsetwall.staticWallpaper must be set when services.xsetwall.mode is \"static\".";
      }
    ];

    systemd.user.services.xsetwall = serviceUnit;

    systemd.user.timers = lib.optionalAttrs cycling { xsetwall = timerUnit; };
  };
}
