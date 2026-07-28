{ vacuModules, ... }: {
  imports = [ vacuModules.nixOnDroidTermuxProperties ];
  vacu.termuxProperties.extra-keys = ''
    [ \
      ['ESC','KEYBOARD','PASTE', 'HOME', 'UP'  , 'END' , 'PGUP'],\
      ['TAB', 'CTRL'   , 'ALT' , 'LEFT', 'DOWN','RIGHT', 'PGDN']\
    ]'';
}
