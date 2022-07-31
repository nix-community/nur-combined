{ config, lib, pkgs, ... }: with lib; let
  toPropertyValue = value:
    if value == true then "true"
    else if value == false then "false"
    else toString value;
  defaultUpdated = "1970-01-01T00:00:00Z";
  filterModule = { config, name, ... }: {
    options = {
      title = mkOption {
        type = types.str;
        default = "Mail Filter";
      };
      updated = mkOption {
        type = types.str;
        default = defaultUpdated;
      };
      id = mkOption {
        type = types.str;
        default = name;
      };
      content = mkOption {
        type = types.str;
        default = "";
      };
      properties = mkOption {
        type = with types; attrsOf (oneOf [ str bool ]);
        default = { };
      };
      out = {
        xmlContent = mkOption {
          type = types.lines;
        };
      };
    };
    config = {
      properties = mapAttrs (_: mkOptionDefault) {
        sizeOperator = "s_sl";
        sizeUnit = "s_smb";
      };
      out.xmlContent = mkMerge (singleton (mkBefore ''
        <category term='filter'></category>
        <title>${config.title}</title>
        <id>tag:mail.google.com,2008:filter:${config.id}</id>
        <updated>${config.updated}</updated>
        <content>${config.content}</content>
      '') ++ mapAttrsToList (key: value: ''<apps:property name='${key}' value='${toPropertyValue value}'/>'') config.properties);
    };
  };
  emailModule = { config, ... }: let
    ids = concatStringsSep "," (mapAttrsToList (_: filter: filter.id) config.gmail.filters);
    updated' = mapAttrsToList (_: filter: filter.updated) config.gmail.filters;
    updated = if updated' == [ ] then defaultUpdated else head updated';
    filterXmls = mapAttrsToList (_: filter: ''
      <entry>
      ${filter.out.xmlContent}
      </entry>
    '') config.gmail.filters;
  in {
    options.gmail = {
      filters = mkOption {
        type = with types; attrsOf (submodule filterModule);
        default = { };
      };
      out = {
        filterXmlContent = mkOption {
          type = types.lines;
        };
        filterXmlFile = mkOption {
          type = types.package;
        };
      };
    };
    config.gmail = {
      out = {
        filterXmlContent = mkMerge ([
          (mkBefore ''
            <?xml version='1.0' encoding='UTF-8'?>
            <feed xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'>
              <title>Mail Filters</title>
              <id>tag:mail.google.com,2008:filters:${ids}</id>
              <updated>${updated}</updated>
              <author>
                <name>${config.realName}</name>
                <email>${config.address}</email>
              </author>
          '')
          (mkAfter ''
            </feed>
          '')
        ] ++ filterXmls);
        filterXmlFile = pkgs.writeText "mailFilters.xml" config.gmail.out.filterXmlContent;
      };
    };
  };
in {
  options = {
    accounts.email.accounts = mkOption {
      type = with types; attrsOf (submodule emailModule);
    };
  };
}
