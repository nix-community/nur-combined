### Get Started

1. **Open PowerShell as Administrator.**
   - Search for "PowerShell" in the Start menu, right-click, and select "Run as Administrator."
2. **Create hard links by running the following commands,** replacing `<SOURCE_PATH>` with the full path to your original files:

   - Hard link for `ac-with-glazewm.css`:

     ```powershell
     New-Item -ItemType HardLink -Path "C:\Users\<USER_NAME>\.glzr\zebar\starter\ac-with-glazewm.css" -Target "<SOURCE_PATH>\ac-with-glazewm.css"
     ```

   - Hard link for `ac-with-glazewm.html`:

     ```powershell
     New-Item -ItemType HardLink -Path "C:\Users\<USER_NAME>\.glzr\zebar\starter\ac-with-glazewm.html" -Target "<SOURCE_PATH>\ac-with-glazewm.html"
     ```

   - Hard link for `ac-with-glazewm.zebar.json`:

     ```powershell
     New-Item -ItemType HardLink -Path "C:\Users\<USER_NAME>\.glzr\zebar\starter\ac-with-glazewm.zebar.json" -Target "<SOURCE_PATH>\ac-with-glazewm.zebar.json"
     ```

3. **Open the tray icon menu:**
   - Right-click the tray icon of the application.
4. **Cancel the current active configuration:**
   - In the context menu, find the currently active configuration and deselect or disable it.
5. **Enable your configuration:**
   - From the same context menu, locate and select your configuration to enable it.
6. **Enable "Launch on startup":**
   - After enabling your configuration, make sure to check the "Launch on startup" option, usually found in the tray menu under "Settings" or similar.
