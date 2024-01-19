-- Base
import XMonad
import System.Directory
import System.IO (hClose, hPutStr, hPutStrLn)
import System.Exit (exitWith, ExitCode( ExitSuccess ))
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.WorkspaceHistory

-- Layouts
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimplestFloat
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.Spiral
import XMonad.Layout.Fullscreen

    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Magnifier
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP, mkNamedKeymap)
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook, trayerPaddingXmobarEventHook, trayPaddingXmobarEventHook, trayPaddingEventHook)
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "gnome-terminal"

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]

-- Workspaces --
xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces    = ["www", "code", "misc"] ++ map [4..9]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#ffffff"
myFocusedBorderColor = "#ccff00"

-- SCRATCHPADS
scratchpads = [ NS "ranger" "st -c 'ranger' -e ranger" (className =? "ranger") manageTerm
              ,  NS "notes" "st -c 'scratchpad' -e 'nvim'" (className =? "scratchpad") manageTerm
              ,  NS "pavu" "pavucontrol" (className =? "Pavucontrol") manageWindow
              ,  NS "tor" "exec gtk-launch start-tor-browser" (className =? "Tor Browser") manageTerm
              ,  NS "bitwarden" "bitwarden-desktop" (className =? "Bitwarden") manageWindow
              ,  NS "st" "st" (className =? "StScratchpad") manageWindow
              ,  NS "networkmanager" "nm-connection-editor" (className =? "Nm-connection-editor") manageWindow
              ,  NS "bluetooth" "blueman-manager" (className =? "Blueman-manager") manageWindow
              ,  NS "trello" "npm start --prefix ~/Applications/trello/" (className =? "Trello") manageTerm
              ]
  where
manageTerm = customFloating $ W.RationalRect l t w h
           where
             h = 0.9
             w = 0.9
             t = 0.95 -h
             l = 0.95 -w

manageWindow = customFloating $ W.RationalRect l t w h
           where
             h = 0.6
             w = 0.6
             t = 0.80 -h
             l = 0.80 -w

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run | dmenu -b")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window 
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap (used with avoidStruts from Hooks.ManageDocks)
    , ((modm , xK_b ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), restart "xmonad" True)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- Spacing
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

-- Defining Layouts
tall     = renamed [Replace "Tall"]
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (1/100) (1/2) []

threeCol = renamed [Replace "Unflexed"]
          $ mySpacing 3
          $ ThreeColMid 1 (1/10) (1/2)

monocle  = renamed [Replace "Monocle"]
           $ limitWindows 20 Full

myLayoutHook = avoidStruts
              $ mouseResize
              $ windowArrange
              $ T.toggleLayouts monocle
              $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout = threeCol
                                ||| noBorders monocle
                                ||| tall
                                ||| threeCol

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

------------------------------------------------------------------------
-- Startup scripts 
--
-- bash scripts located in ~/.dotfiles/xmonad/<script> 
-- that get symlinked to /usr/bin/<script>

myStartupHook = do
    spawnOnce "set-wallpaper"
    spawnOnce "compton &"

------------------------------------------------------------------------
-- Run xmonad with the settings you specify. No need to modify this.

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

activeColor = "#00ccff"
inactiveColor = "#ffffff"
separatorColor = "#ffffff"
urgentColor = "#ff0000"
color05 = "#00ccff"
color09 = "#00ccff"
color16 = "#00ccff"

main = do 
  -- Launch xmobar
  xmproc <- spawnPipe "xmobar -x 0 ~/.dotfiles/xmonad/xmobar.config"
  -- Lauch XMonad
  xmonad $ docks $ def {
      -- General stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- Key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- Hooks
        layoutHook         = myLayoutHook,
        manageHook         = manageDocks <+> namedScratchpadManageHook scratchpads <+> manageHook def,
        startupHook        = myStartupHook,
        logHook = dynamicLogWithPP $ xmobarPP
                { ppOutput = hPutStrLn xmproc,
                  ppCurrent = xmobarColor activeColor "" . wrap
                              "[ " " ]",
                  -- Visible but not current workspace
                  ppVisible = xmobarColor inactiveColor "",
                  -- Hidden workspace
                  ppHidden = xmobarColor inactiveColor "" . wrap
                              "[ " " ]",
                  -- Hidden workspaces (no windows)
                  ppHiddenNoWindows = xmobarColor inactiveColor "". wrap
                              "[ " " ]",
                  -- Title of active window
                  ppTitle = (\str -> ""),
                  -- Separator character
                  ppSep =  "<fc=" ++ separatorColor ++ "> <fn=1>|</fn> </fc>",
                  -- Urgent workspace
                  ppUrgent = xmobarColor urgentColor "" . wrap "!" "!",
                  -- Order of things in xmobar
                  ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                }

    }
