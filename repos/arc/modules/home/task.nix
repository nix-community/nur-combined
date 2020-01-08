{ lib, config, ... }: with lib; let
  cfg = config.programs.taskwarrior;
  formatColor = color: concatStringsSep " " (
    (if color.foreground != null then [color.foreground] else []) ++
    (if color.background != null then ["on ${color.background}"] else [])
  );
  mapUdaAttr = apply: name: value:
    if value != null then [(nameValuePair name (apply value))] else [];
  udaConfig = name: uda:
    (udaAttrs name uda) ++
    (udaUrgencies name uda) ++
    (udaColors name uda);
  udaAttrs = name: uda: mapAttrsToList
    (n: v: nameValuePair "uda.${name}.${n}" v)
    (filterAttrs (_: v: v != null) {
      inherit (uda) type label default indicator;
      values = if length uda.values > 0
        then map (v: v.value) uda.values
        else null;
    });
  udaUrgencies = name: uda: let
    urgencies = [(nameValuePair name uda.urgencyCoefficient)] ++ (map
      (v: nameValuePair "${name}.${v.value}" v.urgencyCoefficient)
      uda.values
    );
  in mapAttrsToList
    (name: value: mapUdaAttr id "urgency.uda.${name}.coefficient" value)
    (listToAttrs urgencies);
  udaColors = name: uda: let
    colors = [
      (nameValuePair name uda.color)
      (nameValuePair "${name}.none" uda.noneColor)
    ] ++ (map (v: nameValuePair "${name}.${v.value}" v.color) uda.values);
  in mapAttrsToList
    (name: mapUdaAttr formatColor "color.uda.${name}")
    (listToAttrs colors);
  colorType = types.submodule {
    options = {
      foreground = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Foreground color.";
      };
      background = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Background color.";
      };
    };
  };
  udaValueType = types.submodule {
    options = {
      value = mkOption {
        type = types.str;
        description = "Acceptable attribute value.";
      };
      urgencyCoefficient = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Task urgency coefficient used when this value is set.
        '';
      };
      color = mkOption {
        type = types.nullOr colorType;
        default = null;
        description = "Color any task that has this value.";
      };
    };
  };
  udaType = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "string" "numeric" "date" "duration" ];
        description = "The value type of the attribute.";
      };
      label = mkOption {
        type = types.str;
        description = "A default report label for the attribute.";
      };
      values = mkOption {
        type = types.listOf udaValueType;
        default = [ ];
        description = "A list of acceptable values for a string attribute.";
      };
      indicator = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The character or string to show in the 'uda.indicator' report column.
        '';
      };
      default = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Default value when using the 'task add' command.";
      };
      urgencyCoefficient = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Task urgency coefficient based on the presence of this attribute.
        '';
      };
      color = mkOption {
        type = types.nullOr colorType;
        default = null;
        description = "Color any task that has this attribute.";
      };
      noneColor = mkOption {
        type = types.nullOr colorType;
        default = null;
        description = "Color any task that does not have this attribute.";
      };
    };
  };
  sortType = types.submodule {
    options = {
      priority = mkOption {
        type = types.int;
        default = 1000;
        description = ''
          The order in which the column is sorted,
          where zero is the highest priority.

          Use this when the column display order
          differs from the sort order.
        '';
      };
      order = mkOption {
        type = types.enum [ "ascending" "descending" ];
        default = "ascending";
        description = ''
          Column data sort order.
        '';
      };
      visualBreak = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Indicates that there are breaks after the column values change.

          A listing break is simply a blank line
          that provides a visual grouping.
        '';
      };
    };
  };
  columnType = types.submodule ({ config, ... }: {
    options = {
      id = mkOption {
        type = types.str;
        description = ''
          Column value type name.

          See the command 'task columns' for a full list of options and examples.
        '';
      };
      format = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Optional formatting specifier for the column value.

          See the command 'task columns' for a full list of supported formats.
        '';
      };
      label = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The label for the column that will be used when generating the report.
        '';
      };
      sort = mkOption {
        type = types.nullOr sortType;
        default = null;
        description = ''
          Set this to sort the report based on the value in this column.
        '';
      };
    };
  });
  reportType = types.submodule {
    options = {
      columns = mkOption {
        type = types.listOf columnType;
        description = ''
          The report's columns and their formatting specifiers.
        '';
      };
      filter = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Only tasks matching the filter criteria are
          displayed in the generated report.
        '';
      };
      dateFormat = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Used by the 'due date' column.

          See the DATES section in 'man 5 taskrc' for details.
        '';
      };
      description = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          The description when running the 'task help' command.
        '';
      };
    };
  };
  mapReport = name: report: let
    labelled = filter (col: col.label != null) report.columns;
    sorted = filter (col: col.sort != null) report.columns;
    sorted' = sort (a: b: a.sort.priority < b.sort.priority) sorted;
    columnString = col: col.id +
      (if col.format != null then ".${col.format}" else "");
    sortString = col: col.id +
      (if col.sort.order == "ascending" then "+" else "-") +
      (if col.sort.visualBreak then "/" else "");
  in {
    ${if report.description != null then "description" else null} =
      report.description;
    ${if report.filter != null then "filter" else null} =
      report.filter;
    ${if report.dateFormat != null then "dateformat" else null} =
      report.dateFormat;
    columns = map columnString labelled;
    labels = map (col: col.label) labelled;
    sort = map sortString sorted';
  };
  contextName = name: value: nameValuePair "context.${name}" value;
  contextConfig = (if cfg.activeContext != null then {
    context = cfg.activeContext;
  } else { }) // (mapAttrs' contextName cfg.contexts);
in {
  options.programs.taskwarrior = {
    reports = mkOption {
      type = types.attrsOf reportType;
      default = { };
      description = ''
        Specify custom taskwarrior reports.
      '';
      example = literalExample ''
        {
          short = {
            description = "My custom filter";
            filter = "status:pending +READY";
            columns = [
              {
                label = "ID";
                id = "id";
              }
              {
                label = "Description";
                id = "description";
                format = "count";
              }
              {
                id = "urgency";
                label = "Urgency";
                sort.order = "descending";
              }
            ];
          };
        };
      '';
    };
    contexts = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = { work = "project:work"; };
      description = ''
        User-defined context filters.
      '';
    };
    activeContext = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The active context applies a permanent filter to all task commands.
      '';
    };
    aliases = mkOption {
      type = types.attrsOf types.str;
      default = { rm = "delete"; };
      description = "Provide an alternate name for a command.";
    };
    userDefinedAttributes = mkOption {
      type = types.attrsOf udaType;
      default = { };
      description = ''
        Custom UDA definitions.
      '';
    };
    taskd = {
      server = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "host.name:53589";
        description = ''
          Specifies the hostname and port of the Taskserver.

          Hostname may be an IPv4 or IPv6 address, or domain.
          Port is an integer.
        '';
      };
      authorityCertificate = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Specifies the path to the CA certificate in the event
          that your Taskserver is using a self-signed certificate.
        '';
      };
      clientCredentials = mkOption {
        type = types.str;
        example = "<organization>/<user>/<key>";
        description = ''
          User identification for the Taskserver,
          which includes a private key.
        '';
      };
      clientCertificate = mkOption {
        type = types.path;
        description = ''
          Specifies the path to the client certificate
          used for identification with the Taskserver.
        '';
      };
      clientKey = mkOption {
        type = types.path;
        description = ''
          Specifies the path to the client key used for
          encrypted communication with the Taskserver.
        '';
      };
      trust = mkOption {
        type = types.enum [ "strict" "ignore hostname" "allow all" ];
        default = "strict";
        description = ''
          This settings allows you to override the trust level
          when server certificates are validated.

          With 'allow all', the server certificate is trusted automatically.

          With 'ignore hostname', the server certificate is verified
          but the hostname is ignored.

          With 'strict', the server certificate is verified.
        '';
      };
    };
  };

  config.programs.taskwarrior.config = {
    taskd = if (cfg.taskd.server != null) then {
      server = cfg.taskd.server;
      credentials = "${cfg.taskd.clientCredentials}";
      ${if cfg.taskd.authorityCertificate != null then "ca" else null} =
        "${cfg.taskd.authorityCertificate}";
      certificate = "${cfg.taskd.clientCertificate}";
      key = "${cfg.taskd.clientKey}";
      trust = cfg.taskd.trust;
    } else { };
    report = mapAttrs mapReport cfg.reports;
    alias = cfg.aliases;
  } // contextConfig
  // (listToAttrs (flatten (mapAttrsToList udaConfig cfg.userDefinedAttributes)));
}
