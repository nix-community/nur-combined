!include "MUI2.nsh"

; ── Meta ────────────────────────────────────────────────────────────────────
!define APP_NAME    "Instant Eyedropper Reborn"
!define APP_EXE     "ie-r.exe"
!define TRAY_EXE    "ie-r-tray.exe"
!define APP_VERSION "0.1.1"
!define PUBLISHER   "Konstantin Yagola"
!define URL         "https://instant-eyedropper.com"
!define REG_UNINST  "Software\Microsoft\Windows\CurrentVersion\Uninstall\ie-r"
!define REG_RUN     "Software\Microsoft\Windows\CurrentVersion\Run"

; ── Paths (passed from build script via -DBUNDLE and -DOUTDIR) ──────────────
!ifndef BUNDLE
    !define BUNDLE "ie-r-windows"
!endif
!ifndef OUTDIR
    !define OUTDIR "."
!endif

; ── Output ──────────────────────────────────────────────────────────────────
Name            "${APP_NAME}"
OutFile         "${OUTDIR}/ie-r-setup-v${APP_VERSION}.exe"
InstallDir      "$LOCALAPPDATA\ie-r"
RequestExecutionLevel user

; ── Pages ───────────────────────────────────────────────────────────────────
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN          "$INSTDIR\${TRAY_EXE}"
!define MUI_FINISHPAGE_RUN_TEXT     "Launch ${APP_NAME}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; ── Close running instances (used in both install and uninstall) ──────────────
!macro CloseRunningApp
    DetailPrint "Stopping running instances..."
    nsExec::Exec '"$SYSDIR\taskkill.exe" /F /IM "${APP_EXE}"'
    Pop $0
    nsExec::Exec '"$SYSDIR\taskkill.exe" /F /IM "${TRAY_EXE}"'
    Pop $0
    Sleep 500
!macroend

; ── Sections ─────────────────────────────────────────────────────────────────
Section "!IE-R" SEC_MAIN
    SectionIn RO
    !insertmacro CloseRunningApp
    SetOutPath "$INSTDIR"
    File "${BUNDLE}/${APP_EXE}"
    File "${BUNDLE}/${TRAY_EXE}"
    File "${BUNDLE}/LICENSE"
    File "${BUNDLE}/README.md"
    File "${BUNDLE}/PRIVACY.md"
    File "${BUNDLE}/SECURITY.md"

    ; Start Menu shortcut — must be before SetOutPath changes $OUTDIR
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" \
        "$INSTDIR\${TRAY_EXE}" "" "$INSTDIR\${TRAY_EXE}"

    SetOutPath "$INSTDIR\fonts"
    File "${BUNDLE}/fonts/*.*"

    WriteUninstaller "$INSTDIR\uninstall.exe"

    ; Programs & Features / Settings → Apps
    WriteRegStr  HKCU "${REG_UNINST}" "DisplayName"     "${APP_NAME}"
    WriteRegStr  HKCU "${REG_UNINST}" "DisplayVersion"  "${APP_VERSION}"
    WriteRegStr  HKCU "${REG_UNINST}" "Publisher"       "${PUBLISHER}"
    WriteRegStr  HKCU "${REG_UNINST}" "URLInfoAbout"    "${URL}"
    WriteRegStr  HKCU "${REG_UNINST}" "InstallLocation" "$INSTDIR"
    WriteRegStr  HKCU "${REG_UNINST}" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr  HKCU "${REG_UNINST}" "DisplayIcon"     "$INSTDIR\${TRAY_EXE}"
    WriteRegDWORD HKCU "${REG_UNINST}" "NoModify"       1
    WriteRegDWORD HKCU "${REG_UNINST}" "NoRepair"       1
SectionEnd

Section /o "Desktop shortcut" SEC_DESKTOP
    SetOutPath "$INSTDIR"
    CreateShortcut "$DESKTOP\${APP_NAME}.lnk" \
        "$INSTDIR\${TRAY_EXE}" "" "$INSTDIR\${TRAY_EXE}"
SectionEnd

Section /o "Run at Windows startup" SEC_AUTOSTART
    WriteRegStr HKCU "${REG_RUN}" "ie-r" '"$INSTDIR\${TRAY_EXE}"'
SectionEnd

; ── Uninstall ────────────────────────────────────────────────────────────────
Section "Uninstall"
    !insertmacro CloseRunningApp
    Delete "$INSTDIR\${APP_EXE}"
    Delete "$INSTDIR\${TRAY_EXE}"
    Delete "$INSTDIR\LICENSE"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\PRIVACY.md"
    Delete "$INSTDIR\SECURITY.md"
    RMDir /r "$INSTDIR\fonts"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"

    Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
    RMDir  "$SMPROGRAMS\${APP_NAME}"
    Delete "$DESKTOP\${APP_NAME}.lnk"

    DeleteRegKey   HKCU "${REG_UNINST}"
    DeleteRegValue HKCU "${REG_RUN}" "ie-r"
SectionEnd
