{ config, lib, pkgs, ... }: with lib; let
  cfg = config.hardware.alsa;
  arc = import ../../canon.nix { inherit pkgs; };
  alsa = lib.alsa or arc.lib.alsa;
  inherit (alsa) alsaConf alsaDirectiveType;
  mappingType = { config, name, ... }: {
    device-strings = mkOption {
      type = types.str;
      default = "${name}:%f";
    };
    exact-channels = mkOption {
      type = types.bool;
      default = false;
    };
    channel-map = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    description = mkOption {
      type = types.str;
      default = name;
    };
    paths-input = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    paths-output = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    direction = mkOption {
      type = types.enum [ null "input" "output" ];
      default = null;
    };
  };
  profileType = { config, name, ... }: {
    description = mkOption {
      type = types.str;
      default = name;
    };
  };
  pathType = { config, name, ... }: {
  };
  csetValuePrimitiveType = with types; oneOf [ str int bool ];
  csetValueType = with types; either (listOf csetValuePrimitiveType) csetValuePrimitiveType;
  mapDeviceName = devices: dev: devices.${dev}.name or (throw "UCM device ${dev} not found");
  comment = name: mkOption {
    type = with types; nullOr str;
    default = name;
  };
  value = mkOption {
    type = with types; attrsOf (oneOf [ str int float ]);
    default = { };
  };
  set = mkOption {
    type = with types; attrsOf csetValueType;
    default = { };
  };
  ctl = mkOption {
    type = types.str;
    default = "hw:\${CardId}";
  };
  csetValueStr = value:
    if value == true then "on"
    else if value == false then "off"
    else if isList value then concatMapStringsSep "," csetValueStr value
    else toString value;
  fromSet = mapAttrsToList (name: value: {
    cset = let
      name' = splitString "," name;
      index = elemAt name' 1;
    in {
      name = mkDefault (head name');
      index = mkIf (length name' > 1) (mkDefault (toInt index));
      value = mkDefault value;
    };
  });
  fromValue = { jack ? null, playback ? null, capture ? null, toneQuality ? null }@args: let
    mapValue = value: mkIf (value != null) (mkOptionDefault value);
  in mapListToAttrs (item: setAttr item "value" (mapValue item.value)) ([
    (nameValuePair "TQ" toneQuality)
  ] ++ optionals (args ? jack) [
    (nameValuePair "JackCTL" jack.ctl)
    (nameValuePair "JackDev" jack.dev)
    (nameValuePair "JackControl" jack.control)
    (nameValuePair "JackHWMute" jack.hwMute)
  ] ++ optionals (args ? playback) [
    (nameValuePair "PlaybackPriority" playback.priority)
    (nameValuePair "PlaybackRate" playback.rate)
    (nameValuePair "PlaybackChannels" playback.channels)
    (nameValuePair "PlaybackCTL" playback.ctl)
    (nameValuePair "PlaybackPCM" playback.pcm)
    (nameValuePair "PlaybackMixer" playback.mixerName)
    (nameValuePair "PlaybackMixerElem" playback.mixer)
    (nameValuePair "PlaybackMasterElem" playback.master)
    (nameValuePair "PlaybackVolume" playback.volume)
    (nameValuePair "PlaybackSwitch" playback.switch)
  ] ++ optionals (args ? capture) [
    (nameValuePair "CapturePriority" capture.priority)
    (nameValuePair "CaptureRate" capture.rate)
    (nameValuePair "CaptureChannels" capture.channels)
    (nameValuePair "CaptureCTL" capture.ctl)
    (nameValuePair "CapturePCM" capture.pcm)
    (nameValuePair "CaptureMixer" capture.mixerName)
    (nameValuePair "CaptureMixerElem" capture.mixer)
    (nameValuePair "CaptureMasterElem" capture.master)
    (nameValuePair "CaptureVolume" capture.volume)
    (nameValuePair "CaptureSwitch" capture.switch)
  ]);
  enableSequence = mkOption {
    type = with types; listOf (submodule sequenceElementType);
    default = [ ];
  };
  disableSequence = enableSequence;
  toneQuality = mkOption {
    type = with types; nullOr str;
    default = null;
  };
  playback = mkOption {
    type = types.submodule valueCommon;
    default = { };
  };
  capture = playback;
  valueCommon = { config, ... }: {
    options = {
      priority = mkOption {
        type = with types; nullOr int;
        default = null;
      };
      rate = mkOption {
        type = with types; nullOr int;
        default = null;
      };
      channels = mkOption {
        type = with types; nullOr int;
        default = null;
      };
      pcm = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      ctl = mkOption {
        type = with types; nullOr str;
        default = config.pcm;
      };
      mixerName = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      mixer = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      master = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      volume = mkOption {
        type = with types; nullOr str;
        default = null; # mapNullable (m: "${m} Volume") config.mixer;
      };
      switch = mkOption {
        type = with types; nullOr str;
        default = null; # mapNullable (m: "${m} Switch") config.mixer;
      };
    };
  };
  jack = {
    ctl = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    dev = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    control = mkOption {
      type = with types; nullOr str;
      default = null;
    };
    hwMute = mkOption {
      type = with types; nullOr str;
      default = null;
    };
  };
  sequenceElementType = { config, options, ... }: {
    options = {
      cdev = {
        device = mkOption {
          type = types.str;
        };
      };
      cset = {
        kind = mkOption {
          type = types.enum [ "set" "bin-file" "tlv" "new" ];
          default = "set";
        };
        name = mkOption {
          type = types.str;
        };
        index = mkOption {
          type = with types; nullOr int;
          default = null;
        };
        value = mkOption {
          type = csetValueType;
        };
        out = {
          type = mkOption {
            type = types.str;
            internal = true;
          };
        };
      };
      ctl-remove.device = mkOption {
        type = types.str;
      };
      enadev.device = mkOption {
        type = types.str;
      };
      disdev.device = mkOption {
        type = types.str;
      };
      exec = {
        command = mkOption {
          type = types.str;
        };
      };
      shell = {
        command = mkOption {
          type = types.str;
        };
      };
      sleep = {
        amount = mkOption {
          type = types.int;
        };
        unit = mkOption {
          type = types.oneOf [ "milliseconds" "microseconds" ];
          default = "microseconds";
        };
        out = {
          type = mkOption {
            type = types.str;
            internal = true;
          };
        };
      };
      sysw.value = mkOption {
        type = types.str;
      };
      cfg-save.value = mkOption {
        type = types.str;
      };
      out = {
        directive = mkOption {
          type = types.attrsOf types.str;
          internal = true;
        };
        type = mkOption {
          type = types.str;
          internal = true;
        };
        value = mkOption {
          type = types.str;
          internal = true;
        };
      };
    };

    config = {
      # TODO: consider string escape requirements
      out = mkMerge [
        (mkIf options.cset.value.isDefined {
          type = config.cset.out.type;
          value = mkOptionDefault ''name='${config.cset.name}'${optionalString
            (config.cset.index != null) ",index=${toString config.cset.index}"
          } ${csetValueStr config.cset.value}'';
        })
        (mkIf options.cdev.device.isDefined {
          type = "cdev";
          value = mkOptionDefault config.cdev.device;
        })
        (mkIf options.ctl-remove.device.isDefined {
          type = "ctl-remove";
          value = mkOptionDefault config.ctl-remove.device;
        })
        (mkIf options.enadev.device.isDefined {
          type = "enadev";
          value = mkOptionDefault config.enadev.device;
        })
        (mkIf options.disdev.device.isDefined {
          type = "disdev";
          value = mkOptionDefault config.disdev.device;
        })
        (mkIf options.exec.command.isDefined {
          type = "exec";
          value = mkOptionDefault config.exec.command;
        })
        (mkIf options.shell.command.isDefined {
          type = "shell";
          value = mkOptionDefault config.shell.command;
        })
        (mkIf options.sysw.value.isDefined {
          type = "sysw";
          value = mkOptionDefault config.sysw.value;
        })
        (mkIf options.cfg-save.value.isDefined {
          type = "cfg-save";
          value = mkOptionDefault config.cfg-save.value;
        })
        (mkIf options.sleep.amount.isDefined {
          type = config.sleep.out.type;
          value = mkOptionDefault (toString config.sleep.amount);
        })
        {
          directive = mkOptionDefault {
            ${config.out.type} = config.out.value;
          };
        }
      ];
      sleep.out.type = mkOptionDefault {
        milliseconds = "msleep";
        microseconds = "usleep";
      }.${config.sleep.unit};
      cset.out.type = mkOptionDefault {
        set = "cset";
      }.${config.cset.kind} or "cset-${config.cset.kind}";
    };
  };
  ucmUseCaseType = { config, name, devices, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };
      comment = comment name;
      inherit set value enableSequence disableSequence toneQuality;
      supportedDevice = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      conflictingDevice = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      devices = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      modifiers = mkOption {
        type = with types; attrsOf (submoduleWith {
          modules = [
            ucmDeviceType
            {
              config._module.args.modifier = true;
            }
          ];
          specialArgs = {
            inherit devices;
          };
        });
        default = { };
      };
      transitions = mkOption {
        type = types.attrsOf (enableSequence.type);
        default = { };
      };
      out.directive = mkOption {
        type = types.listOf (types.attrsOf alsaDirectiveType);
        internal = true;
      };
    };
    config = {
      enableSequence = fromSet config.set;
      value = fromValue {
        inherit (config) toneQuality;
      };
      out.directive = mkMerge [ [ {
        SectionVerb = {
          EnableSequence = mkIf (config.enableSequence != [ ]) (
            map (s: s.out.directive) config.enableSequence
          );
          DisableSequence = mkIf (config.disableSequence != [ ]) (
            map (s: s.out.directive) config.disableSequence
          );
          SupportedDevice = mkIf (config.supportedDevice != [ ]) (
            map (mapDeviceName devices) config.supportedDevice
          );
          ConflictingDevice = mkIf (config.conflictingDevice != [ ]) (
            map (mapDeviceName devices) config.conflictingDevice
          );
          Value = mkIf (config.value != { }) config.value;
        };
        SectionDevice = mkIf (config.devices != [ ]) (mapListToAttrs (name: let
          device = devices.${name};
        in nameValuePair device.name device.out.directive) config.devices);
        SectionModifier = mkIf (config.modifiers != { }) (listToAttrs (imap0 (index: mod:
          nameValuePair mod.name { ${toString index} = mod.out.directive; }
        ) (attrValues config.modifiers)));
        TransitionSequence = mkIf (config.transitions != { }) (mapAttrsToList (name: trans:
          nameValuePair name (mkIf (trans != [ ]) trans)
        ) config.transitions);
      } ]
        /*(mkIf (config.devices != [ ]) (map (name: let
          device = devices.${name};
        in { "SectionDevice.\"${device.name}\"" = device.out.directive; }) config.devices))*/
        /*(mkIf (config.modifiers != { }) (imap0 (index: mod:
          { SectionModifier.${mod.name}.${toString index} = mod.out.directive; }
        ) (attrValues config.modifiers)))*/
        /*(mkIf (config.transitions != { }) (mapAttrsToList (name: trans:
          { "TransitionSequence.\"${name}\"" = mkIf (trans != [ ]) trans; }
        ) config.transitions))*/
      ];
    };
  };
  ucmDeviceType = { config, name, devices, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };
      comment = comment name;
      inherit ctl set jack value enableSequence disableSequence toneQuality playback capture;
      supportedDevice = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      conflictingDevice = mkOption {
        type = with types; listOf str;
        default = [ ];
      };
      transitions = mkOption {
        type = types.attrsOf (enableSequence.type);
        default = { };
      };
      out.directive = mkOption {
        type = types.attrsOf alsaDirectiveType;
        internal = true;
      };
    };

    config = {
      ctl = mkMerge [
        (mkIf (config.playback.ctl != null) (mkDefault config.playback.ctl))
        (mkIf (config.capture.ctl != null) (mkDefault config.capture.ctl))
      ];
      enableSequence = mkMerge [
        (mkBefore [ {
          cdev.device = config.ctl;
        } ])
        (fromSet config.set)
      ];
      value = fromValue {
        inherit (config) jack playback capture toneQuality;
      };
      out.directive = {
        Comment = mkIf (config.comment != null) config.comment;
        EnableSequence = mkIf (config.enableSequence != [ ]) (
          map (s: s.out.directive) config.enableSequence
        );
        DisableSequence = mkIf (config.disableSequence != [ ]) (
          map (s: s.out.directive) config.disableSequence
        );
        SupportedDevice = mkIf (config.supportedDevice != [ ]) (
          map (name: devices.${name}.name) config.supportedDevice
        );
        ConflictingDevice = mkIf (config.conflictingDevice != [ ]) (
          map (name: devices.${name}.name) config.conflictingDevice
        );
        Value = mkIf (config.value != { }) config.value;
        TransitionSequence = mkIf (config.transitions != { }) (mapAttrs' (name: trans:
          nameValuePair name (mkIf (trans != [ ]) trans)
        ) config.transitions);
      };
    };
  };
  ucmCardType = { config, name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };
      cardDriver = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      cardName = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      comment = comment name;
      inherit set;
      bootSequence = enableSequence;
      fixedBootSequence = enableSequence;
      defaults = {
        inherit set jack value toneQuality playback capture ctl;
        section = enableSequence;
      };
      useCases = mkOption {
        type = with types; attrsOf (submoduleWith {
          modules = [
            ucmUseCaseType
            {
              config._module.args = {
                inherit (config) devices;
              };
            }
          ];
        });
        default = {
          default = {
            devices = attrNames config.devices;
          };
        };
      };
      devices = mkOption {
        type = with types; attrsOf (submoduleWith {
          modules = [
            ucmDeviceType
          ];
          specialArgs = {
            inherit (config) devices;
          };
        });
        default = { };
      };
      out = {
        directive = mkOption {
          type = types.listOf (types.attrsOf alsaDirectiveType);
          internal = true;
        };
        configFile = mkOption {
          type = types.package;
          internal = true;
        };
      };
    };
    config = {
      bootSequence = fromSet config.set;
      defaults = {
        ctl = mkMerge [
          (mkIf (config.defaults.playback.ctl != null) (mkDefault config.defaults.playback.ctl))
          (mkIf (config.defaults.capture.ctl != null) (mkDefault config.defaults.capture.ctl))
        ];
        section = mkMerge [
          (mkBefore [ {
            cdev.device = config.defaults.ctl;
          } ])
          (fromSet config.defaults.set)
        ];
        value = fromValue {
          inherit (config.defaults) jack playback capture toneQuality;
        };
      };
      out.directive = mkMerge [ [ {
        Comment = mkIf (config.comment != null) config.comment;
        BootSequence = mkIf (config.bootSequence != [ ]) (
          map (s: s.out.directive) config.bootSequence
        );
        FixedBootSequence = mkIf (config.fixedBootSequence != [ ]) (
          map (s: s.out.directive) config.fixedBootSequence
        );
        SectionDefaults = mkIf (config.defaults.section != [ ]) (
          map (s: s.out.directive) config.defaults.section
        );
        ValueDefaults = mkIf (config.defaults.value != { }) config.defaults.value;
        SectionUseCase = mkIf (config.useCases != { }) (mapAttrs' (name: useCase:
          nameValuePair useCase.name {
            File = let
              file = pkgs.writeText "alsa-ucm-${name}.conf" (alsaConf useCase.out.directive);
              rootRelativeHack = "/../../..";
            in rootRelativeHack + "${file}";
            Comment = useCase.comment;
          }
        ) config.useCases);
      } ] /*(mkIf (config.useCases != { }) (mapAttrsToList (name: useCase: {
        "SectionUseCase.\"${useCase.name}\"" = {
          File = let
            file = pkgs.writeText "alsa-ucm-${name}.conf" (alsaConf useCase.out.directive);
            rootRelativeHack = "/../../..";
          in rootRelativeHack + "${file}";
          Comment = useCase.comment;
        };
      }) config.useCases))*/ ];
      out.configFile = mkOptionDefault (pkgs.writeText "${config.name}.conf" (
        alsaConf config.out.directive
      ));
    };
  };
in {
  options.hardware.alsa = {
    enable = mkEnableOption "alsa" // {
      default = config.sound.enable;
    };
    mappings = mkOption {
      type = with types; attrsOf (submodule mappingType);
      default = { };
    };
    profiles = mkOption {
      type = with types; attrsOf (submodule profileType);
      default = { };
    };
    paths = mkOption {
      type = with types; attrsOf (submodule pathType);
      default = { };
    };
    ucm = {
      enable = mkEnableOption "ALSA Use Case Manager";
      cards = mkOption {
        type = with types; attrsOf (submodule ucmCardType);
      };
      configDirectory = mkOption {
        description = "Directory to be set as ALSA_CONFIG_UCM2";
        type = types.package;
        readOnly = true;
      };
    };
    config = mkOption {
      type = types.attrsOf alsaDirectiveType;
      default = { };
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };
  config = {
    hardware.alsa = {
      ucm = {
        configDirectory = pkgs.linkFarm "alsa-ucm2" ([
          {
            # variable substitutions that can be used: https://github.com/alsa-project/alsa-lib/blob/master/src/ucm/ucm_subs.c#L677
            name = "ucm.conf";
            path = pkgs.writeText "alsa-ucm2.conf" (alsaConf {
              If.driver = {
                Condition = {
                  Type = "String";
                  Empty = "\${CardNumber}";
                };
                True = {
                  UseCasePath.legacy = {
                    Directory = "\${OpenName}";
                    File = "\${OpenName}.conf";
                  };
                };
                False = {
                  Define = {
                    Driver0Path = "class/sound/card\${CardNumber}/device/driver";
                    DriverName = "\${sys:$Driver0Path}";
                  };

                  UseCasePath = {
                    path0driver = {
                      Directory = "\${var:DriverName}";
                      File = "\${CardName}.conf";
                    };
                    path1long = {
                      Directory = "\${CardDriver}";
                      File = "\${CardName}.conf";
                    };
                    path2driver = {
                      Directory = "\${CardDriver}";
                      File = "\${CardDriver}.conf";
                    };
                  };
                };
              };
            });
          }
          {
            name = "conf.d/conf.d.conf";
            path = pkgs.writeText "alsa-ucm2-default.conf" (alsaConf {
              Include.ucm.File = "/ucm.conf";
            });
          }
        ] ++ mapAttrsToList (name: card: {
          name =
            if card.cardDriver != null && card.cardName != null then "${card.cardDriver}/${card.cardName}.conf"
            else "${card.name}.conf";
          path = card.out.configFile;
        }) cfg.ucm.cards);
      };
    };
    /*environment.sessionVariables = {
      ALSA_CONFIG_UCM2 = mkIf cfg.ucm.enable "${cfg.ucm.configDirectory}";
    };*/
    systemd.user.services = mkIf cfg.ucm.enable {
      pipewire-media-session = mkIf config.services.pipewire.media-session.enable {
        environment = {
          ALSA_CONFIG_UCM2 = "${cfg.ucm.configDirectory}";
        };
      };
      wireplumber = mkIf config.services.wireplumber.enable or false {
        environment = {
          ALSA_CONFIG_UCM2 = "${cfg.ucm.configDirectory}";
        };
      };
    };
    environment = mkIf cfg.enable {
      systemPackages = singleton pkgs.alsa-utils;
      etc = {
        "alsa/conf.d/99-config.conf" = mkIf (cfg.config != { }) {
          text = alsaConf cfg.config;
        };
        "alsa/conf.d/99-extra.conf" = mkIf (cfg.extraConfig != "") {
          text = cfg.extraConfig;
        };
      };
    };
    lib = {
      inherit alsa;
    };
  };
}
