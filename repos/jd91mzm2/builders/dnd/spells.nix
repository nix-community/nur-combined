{ fetchFromGitHub, selfLib }:

let
  spells = fetchFromGitHub {
    owner = "vorpalhex";
    repo = "srd_spells";
    rev = "db71e061dd2fce45c3ac4e7bd5da1f364e5432ab";
    sha256 = "ivtdaL6ZCTcr4wVjVTVtiZGOZJRuJVeukZzmfTkP24Y=";
  };
  raw = builtins.fromJSON (builtins.readFile "${spells}/spells.json");

  all = (builtins.map (spell: {
    id = selfLib.toCamelCase spell.name;
    __toString = self: ''
      ${self.name} (${self.id})
      ${self.type}

      -------------
      Casting Time: ${self.casting_time}
      Range: ${self.range}
      Components: ${self.components.raw}
      Duration: ${self.duration}
      -------------

      ${self.description}
    '';
  } // spell) raw);
in {
  inherit all;

  cantrips = builtins.filter (spell: spell.level == "cantrip") all;

  levels = builtins.genList (lvl:
    builtins.filter (spell: spell.level == toString (lvl + 1)) all
  ) 9;

  byName = builtins.listToAttrs (builtins.map (spell: {
    name = spell.id;
    value = spell;
  }) all);
}
