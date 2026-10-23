{ nushell }:

nushell.overrideAttrs (attrs: {
  # Colemak vim movement keys
  postPatch = ''
    ${attrs.postPatch or ""}
    find . -iname '*.rs' | xargs sed -i \
      -e "/KeyCode::Left.*=>/ s/KeyCode::Char('h')\(.*\)=>/KeyCode::Char('h')\1if key.modifiers.is_empty() =>/g" \
      -e "/KeyCode::Down.*=>/ s/KeyCode::Char('j')\(.*\)=>/KeyCode::Char('n')\1if key.modifiers.is_empty() =>/g" \
      -e "/KeyCode::Up.*=>/ s/KeyCode::Char('k')\(.*\)=>/KeyCode::Char('e')\1if key.modifiers.is_empty() =>/g" \
      -e "/KeyCode::Right.*=>/ s/KeyCode::Char('l')\(.*\)=>/KeyCode::Char('i')\1if key.modifiers.is_empty() =>/g" \
      -e "/KeyCode::Enter.*=>/ s/KeyCode::Char('i')\(.*\)=>/KeyCode::Char('u')\1if key.modifiers.is_empty() =>/g" \
      -e "/\(KeyCode::Up\| if \).*=>/! s/KeyCode::Char('e')\(.*\)=>/KeyCode::Char('f')\1if key.modifiers.is_empty() =>/g" \
      -e "/KeyCode::Up.*=>/! s/KeyCode::Char('e')\(.*\)=>/KeyCode::Char('f')\1=>/g"

    substituteInPlace crates/nu-explore/src/explore_config/input.rs \
      --replace-fail "if key.modifiers.is_empty()" "if modifiers.is_empty()"
  '';

  extraRustcOpts = (attrs.extraRustcOpts or [ ]) ++ [
    "-Dunreachable_patterns"
  ];
})
