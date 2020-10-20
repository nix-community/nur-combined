import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

myManageHook = composeAll
    [ className =? "Gimp" --> doFloat
    ]

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ docks def
        { manageHook = myManageHook <+> manageHook def
        , layoutHook = avoidStruts $ layoutHook def
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask
        , terminal = "termite"
        } `additionalKeys`
        [ ((mod4Mask, xK_p), spawn "rofi -show combi")
        ]
