# ✨ Oh My Posh Custom Config

This guide will help you set up [**Oh My Posh**](https://github.com/JanDeDobbeleer/oh-my-posh) as your PowerShell prompt with a custom configuration.
  
## ⚙️ Setup

### 1. **Add Oh My Posh to PowerShell Profile**

To initialize **Oh My Posh** with a custom configuration in your PowerShell environment, you'll need to add a command to your PowerShell profile. Follow these steps:

1. Open a **PowerShell** terminal with Administrator privileges.

2. Edit your PowerShell profile by running the following command:

   ```powershell
   notepad $PROFILE
   ```

   If the profile file doesn’t exist, PowerShell will prompt you to create it.

3. Add the following line at the end of the profile file:

   ```powershell
   oh-my-posh init pwsh --config C:\code\config\PowerShell\ahmetcetinkaya.omp.json | Invoke-Expression
   ```

   - **Explanation**: This command initializes **Oh My Posh** using the custom configuration file located at `C:\code\config\PowerShell\ahmetcetinkaya.omp.json`.
   - Adjust the path to your **Oh My Posh** JSON configuration file as needed.

4. Save and close the profile file.
