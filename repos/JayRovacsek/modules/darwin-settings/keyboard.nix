{
  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771299; # Left command
        HIDKeyboardModifierMappingDst = 30064771296; # Left control
      }
      {
        HIDKeyboardModifierMappingSrc = 30064771296; # Left control
        HIDKeyboardModifierMappingDst = 30064771299; # Left command
      }
      # Going to remove both being rebound to avoid me not realising this
      # some time in the future
      # {
      #   HIDKeyboardModifierMappingSrc = 30064771300; # Right control
      #   HIDKeyboardModifierMappingDst = 30064771303; # Right command
      # }
      # {
      #   HIDKeyboardModifierMappingSrc = 30064771303; # Right command
      #   HIDKeyboardModifierMappingDst = 30064771300; # Right control
      # }
    ];
  };
}
