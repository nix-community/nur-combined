import XMonad
import XMonad.Config.Xfce
-- import XMonad.Hooks.EwmhDesktops (ewmh)
-- import XMonad.Hooks.ManageDocks
-- import System.Taffybar.Support.PagerHints (pagerHints)

main = xmonad $
       -- docks $
       -- ewmh $
       -- pagerHints
       xfceConfig
         { modMask = mod4Mask
         , terminal = "term-256color"
         }
