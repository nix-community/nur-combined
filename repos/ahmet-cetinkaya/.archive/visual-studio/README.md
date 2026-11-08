# 🛠️ Visual Studio Custom Config

This guide will help you set up **Visual Studio** with custom configuration files, including `.editorconfig` for code style, `.vssettings` for IDE settings, and `.vsext` for extension management. These files will enhance your Visual Studio setup for a personalized development experience.

## ⚙️ Setup

### 1. `.editorconfig` (Code Style Configuration)

The `.editorconfig` file is used to define coding styles, such as indentation, line endings, and formatting preferences. This file can be used across multiple editors and IDEs.

#### Steps to Apply `.editorconfig`:

1. **Place `.editorconfig` File in Your Project**:
   - Copy or move your `.editorconfig` file to the root directory of your Visual Studio solution or project. This ensures the settings are applied globally within your project.

2. **Visual Studio automatically detects `.editorconfig`**:
   - Visual Studio will automatically pick up and apply the settings from the `.editorconfig` file in your project directory. You don't need to import or configure anything manually for this.

### 2. `.vssettings` (IDE Settings)

The `.vssettings` file contains Visual Studio's IDE preferences, including editor settings, layout, themes, and other configurations. This allows you to easily share and apply custom IDE settings.

#### Steps to Apply `.vssettings`:

1. **Export Your Custom `.vssettings` File** (If Not Already Done):
   - If you don't have a `.vssettings` file yet, you can export your current settings from Visual Studio by going to:
     ```
     Tools > Import and Export Settings > Export selected environment settings
     ```
   - Save the `.vssettings` file to a location for easy access.

2. **Import the `.vssettings` File**:
   - Open Visual Studio.
   - Go to:
     ```
     Tools > Import and Export Settings > Import selected environment settings
     ```
   - In the dialog, select the `.vssettings` file you want to apply (your custom file) and click **Next**.
   - Select **Yes** to overwrite existing settings (if you wish to replace your current settings) or choose specific settings to import.

3. **Restart Visual Studio** (Optional):
   - After importing, restart Visual Studio to ensure that all settings are applied correctly.

---

### 3. **Install Extensions Using `.vsext`** (Extension Management)

The `.vsext` file format is used to install Visual Studio extensions. These files can be used to manage extensions automatically, and the **Extension Manager** by **Loop8ack** helps install them.

#### Steps to Install Extensions Using `.vsext`:

1. Download and install the **Extension Manager** from the Visual Studio Marketplace:
     [Extension Manager 2022](https://marketplace.visualstudio.com/items?itemName=Loop8ack.ExtensionManager2022)

2. `Tools > Extension Manager 2022 > Import Extensions`
   - Open the **Extension Manager** from the **Tools** menu.
   - Click on **Import Extensions**.
   - Select the `.vsext` file that contains the extensions you want to install.
   - Click **Open** to start the installation process.
