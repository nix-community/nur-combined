#!/usr/bin/env python3
"""Narrow the desktop port by dropping Android-only subsystems.

The port targets Compose Desktop, so a set of upstream features have no JVM
equivalent at all: Android Auto integration, launcher-icon switching, Shazam-style
music recognition (foreground/background services, tiles, capture activity,
notifications), MediaStore library scanning, and Google Cast. They depend on
platform services the port does not have and cannot have, so instead of curating
stubs for their Android APIs we remove them, exactly like the port already removes
MainActivity, the Glance widgets and the AOD screens.

Removal is keyed on names, never on line numbers, so it survives upstream churn:
the nav-graph blocks that registered the removed screens and every import of a
removed package/type are stripped generically.
"""
import os
import re
import shutil

ROOT = 'app/src/main/kotlin/moe/rukamori/archivetune'

# Android-only subsystems: whole package directories.
DROP_DIRS = [
    'androidauto',
    'appicon',
    'musicrecognition',
    'localmedia',
    'cast',
    'discord',
]

# Individual files belonging to those subsystems (their screens and view models).
DROP_FILES = [
    'ui/screens/settings/AndroidAutoSettings.kt',
    'ui/screens/settings/IconScreen.kt',
    'ui/screens/settings/DiscordSettings.kt',
    'ui/screens/settings/AodCustomizedScreen.kt',
    'ui/player/AodClockWidget.kt',
    'ui/player/AodTouchLockOverlay.kt',
    'utils/DiscordRPC.kt',
    'ui/screens/library/LocalSongScreen.kt',
    'viewmodels/AndroidAutoSettingsViewModel.kt',
    'viewmodels/IconViewModel.kt',
    'viewmodels/MusicRecognitionViewModel.kt',
    'viewmodels/LocalSongsViewModel.kt',
]

# Screen directories belonging to those subsystems.
DROP_UI_DIRS = [
    'ui/screens/musicrecognition',
]

# Screens whose nav-graph registration must go with them.
DROP_ROUTE_SCREENS = [
    'AndroidAutoSettings',
    'IconScreen',
    'MusicRecognitionScreen',
    'MusicRecognitionDetailsScreen',
    'LocalSongScreen',
    'DiscordSettings',
    'AodCustomizedScreen',
]

# Imports that can no longer resolve once the above are gone.
DROP_IMPORT_PATTERNS = [
    re.compile(r'^import moe\.rukamori\.archivetune\.'
               r'(androidauto|appicon|musicrecognition|localmedia|cast)\..*$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.viewmodels\.'
               r'(AndroidAutoSettingsViewModel|IconViewModel|MusicRecognitionViewModel'
               r'|LocalSongsViewModel)$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.ui\.screens\.settings\.'
               r'(AndroidAutoSettings|IconScreen)$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.ui\.screens\.library\.'
               r'(LocalSongScreen)$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.ui\.screens\.musicrecognition\..*$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.discord\..*$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.utils\.DiscordRPC$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.ui\.screens\.settings\.'
               r'(DiscordSettings|AodCustomizedScreen)$', re.M),
    re.compile(r'^import moe\.rukamori\.archivetune\.ui\.player\.'
               r'(AodClockWidget|AodTouchLockOverlay)$', re.M),
]

removed = []
for rel in DROP_DIRS + DROP_UI_DIRS:
    full = os.path.join(ROOT, rel)
    if os.path.isdir(full):
        removed.append(rel + '/')
        shutil.rmtree(full)
for rel in DROP_FILES:
    full = os.path.join(ROOT, rel)
    if os.path.exists(full):
        removed.append(rel)
        os.remove(full)


# A nav-graph entry is a *call* — `composable(...) { ... }` or
# `composable<Route>(...) { ... }`. Matching the bare word `composable` would also
# hit `import androidx.navigation.compose.composable`, and the brace-scan from there
# would swallow the whole enclosing function.
COMPOSABLE_CALL = re.compile(r'\bcomposable\s*[<(]')


def drop_blocks(text, names):
    """Remove `composable(...) { ... }` registrations that call one of `names`."""
    while True:
        hit = None
        pos = 0
        while True:
            call = COMPOSABLE_CALL.search(text, pos)
            if call is None:
                break
            idx = call.start()

            # Walk the argument list to its closing paren, so a `{` inside an
            # argument (e.g. `navArgument("id") { ... }`) is not mistaken for the
            # trailing lambda.
            paren = text.find('(', idx)
            depth = 0
            i = paren + 1
            while i < len(text):
                if text[i] == '(':
                    depth += 1
                elif text[i] == ')':
                    if depth == 0:
                        break
                    depth -= 1
                i += 1

            brace = text.find('{', i)
            if brace == -1:
                break
            depth = 0
            end = brace
            while end < len(text):
                if text[end] == '{':
                    depth += 1
                elif text[end] == '}':
                    depth -= 1
                    if depth == 0:
                        break
                end += 1

            block = text[idx:end + 1]
            if any(re.search(r'\b%s\b' % re.escape(n), block) for n in names):
                start = text.rfind('\n', 0, idx) + 1
                hit = (start, end + 1)
                break
            pos = end + 1
        if hit is None:
            return text
        text = text[:hit[0]] + text[hit[1]:]


nav = os.path.join(ROOT, 'ui/screens/NavigationBuilder.kt')
if os.path.exists(nav):
    text = open(nav).read()
    text = drop_blocks(text, DROP_ROUTE_SCREENS)
    open(nav, 'w').write(text)

# Strip imports that refer to removed packages/types, anywhere in the tree.
for dirpath, _, filenames in os.walk(ROOT):
    for fn in filenames:
        if not fn.endswith('.kt'):
            continue
        path = os.path.join(dirpath, fn)
        text = open(path).read()
        new = text
        for pattern in DROP_IMPORT_PATTERNS:
            new = pattern.sub('', new)
        if new != text:
            open(path, 'w').write(new)

print('narrow: dropped %d android-only subsystem entries' % len(removed))
for r in removed:
    print('  - ' + r)
