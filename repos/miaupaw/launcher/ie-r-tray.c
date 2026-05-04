/*
 * ie-r-tray.c — Silent GUI-subsystem launcher for IE-R.
 *
 * Finds ie-r.exe in the same directory and spawns it with CREATE_NO_WINDOW
 * so no console window ever flashes. All command-line arguments are forwarded.
 *
 * Usage: shortcuts and the autostart registry entry point here.
 *        Terminal users run ie-r.exe directly for full ANSI output.
 *
 * Build (cross from Linux):
 *   x86_64-w64-mingw32-windres tray.rc --codepage 65001 -O coff -o tray.o
 *   x86_64-w64-mingw32-gcc -mwindows -O2 -s ie-r-tray.c tray.o -o ie-r-tray.exe
 */

#include <windows.h>
#include <wchar.h>

int WINAPI WinMain(HINSTANCE hInst, HINSTANCE hPrev, LPSTR lpCmdLine, int nShow)
{
    (void)hInst; (void)hPrev; (void)lpCmdLine; (void)nShow;

    /* Locate ie-r.exe next to this launcher */
    WCHAR self[MAX_PATH];
    if (!GetModuleFileNameW(NULL, self, MAX_PATH))
        return 1;

    WCHAR *sep = wcsrchr(self, L'\\');
    if (!sep) return 1;
    wcscpy(sep + 1, L"ie-r.exe");

    /* Skip argv[0] in the full command line to forward remaining args */
    LPWSTR p = GetCommandLineW();
    if (*p == L'"') {
        ++p;
        while (*p && *p != L'"') ++p;
        if (*p) ++p;
    } else {
        while (*p && *p != L' ') ++p;
    }
    while (*p == L' ') ++p;

    /* Build new command line: "path\ie-r.exe" [forwarded args] */
    WCHAR cmd[32768];
    if (*p) _snwprintf(cmd, 32768, L"\"%ls\" %ls", self, p);
    else    _snwprintf(cmd, 32768, L"\"%ls\"",      self);

    if (GetFileAttributesW(self) == INVALID_FILE_ATTRIBUTES) {
        MessageBoxW(NULL,
            L"ie-r.exe not found.\n\nMake sure ie-r-tray.exe and ie-r.exe are in the same folder.",
            L"Instant Eyedropper Reborn", MB_OK | MB_ICONERROR);
        return 1;
    }

    STARTUPINFOW si = {0};
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi = {0};

    if (!CreateProcessW(self, cmd, NULL, NULL, FALSE,
                        CREATE_NO_WINDOW, NULL, NULL, &si, &pi)) {
        MessageBoxW(NULL,
            L"Failed to launch ie-r.exe.",
            L"Instant Eyedropper Reborn", MB_OK | MB_ICONERROR);
        return 1;
    }

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
    return 0;
}
