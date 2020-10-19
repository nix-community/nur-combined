import XMonad
import XMonad.Config.Xfce

main = xmonad $ xfceConfig
         { modMask = mod4Mask
         , terminal = "termite"
         }
