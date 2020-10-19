import XMonad

main = xmonad $ def
         { modMask = mod4Mask
         , terminal = "termite"
         }
