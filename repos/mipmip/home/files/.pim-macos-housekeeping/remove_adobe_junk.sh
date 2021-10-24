#!/bin/bash
## postinstall script to remove CCDA applications

# remove any existing version of the tool
#echo "Moving the CC Cleaner app to Utilities in case users need it later"
#rm -rf /Applications/Utilities/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app ||:
#mv /Applications/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app /Applications/Utilities/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app

# run the cleaner tool to remove EVERYTHING!
#echo "Running the CC Cleaner app with 'removeAll=All' option"
#/Applications/Utilities/Adobe\ Creative\ Cloud\ Cleaner\ Tool.app/Contents/MacOS/Adobe\ Creative\ Cloud\ Cleaner\ Tool --removeAll=All --eulaAccepted=1

# remove Acrobat DC and Lightroom since the cleaner tool fails to do so
#echo "Removing Acrobat DC if present"
#[[ -d /Applications/Adobe\ Acrobat\ DC ]] && jamf policy -event "Adobe Acrobat DC-uninstall" ||:

#echo "Removing Lightroom if present"
#[[ -d /Applications/Adobe\ Lightroom\ CC ]] && rm -rf /Applications/Adobe\ Lightroom\ CC ||:

#echo "Removing XD if present"
#[[ -d /Applications/Adobe\ XD ]] && rm -rf /Applications/Adobe\ XD ||:

#echo "Removing any Adobe 2020 apps if present"
#find /Applications -name "Adobe*2020" -maxdepth 1 -exec rm -rf {} +

#echo "Removing any Adobe 2020 apps if present - second pass"
#find /Applications -name "Adobe*2020" -maxdepth 1 -exec rm -rf {} +

# delete the folders that remain
#echo "Removing Adobe Application Manager if present"
#[[ -d /Applications/Utilities/Adobe\ Application\ Manager ]] && rm -rf /Applications/Utilities/Adobe\ Application\ Manager ||:

#echo "Removing Adobe Installers folder if present"
#[[ -d /Applications/Utilities/Adobe\ Installers ]] && rm -rf /Applications/Utilities/Adobe\ Installers ||:

#echo "Removing Adobe Application Support folder"
#[[ -d /Library/Application\ Support/Adobe ]] && rm -rf /Library/Application\ Support/Adobe ||:

#rm -rf "/Applications/Adobe*"
#sudo rm -rf "/Applications/Utilities/Adobe*"

launchctl stop com.adobe.acc.AdobeDesktopService.2252.965FE800-C621-41D6-898D-821201FB2F8A
launchctl stop com.adobe.AdobeCreativeCloud
launchctl stop com.adobe.GC.Scheduler-1.0
launchctl stop com.adobe.CCXProcess.7436
launchctl stop com.adobe.accmac.7440

launchctl remove com.adobe.acc.AdobeDesktopService.2252.965FE800-C621-41D6-898D-821201FB2F8A
launchctl remove com.adobe.AdobeCreativeCloud
launchctl remove com.adobe.GC.Scheduler-1.0
launchctl remove com.adobe.CCXProcess.7436
launchctl remove com.adobe.accmac.7440

sudo launchctl stop com.adobe.adobeupdatedaemon
sudo launchctl stop Adobe_Genuine_Software_Integrity_Service
sudo launchctl stop com.adobe.fpsaud

sudo launchctl remove com.adobe.adobeupdatedaemon
sudo launchctl remove Adobe_Genuine_Software_Integrity_Service
sudo launchctl remove com.adobe.fpsaud

sudo rm -rf "/Library/Application Support/Adobe/"
sudo rm -rf "/Users/Shared/Adobe/"
sudo rm -rf /Applications/Adobe*
sudo rm -rf /Applications/Utilities/Adobe*
sudo rm -rf /Library/Application\ Support/Adobe
sudo rm -rf /Library/Preferences/com.adobe.*
sudo rm -rf /Library/PrivilegedHelperTools/com.adobe.*
sudo rm -rf /private/var/db/receipts/com.adobe.*
sudo rm -rf /private/tmp/adobe*

rm -rf "~/Library/Caches/Adobe*/"
rm -rf ~/Library/Application\ Support/Adobe*
rm -rf ~/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.adobe*
rm -rf ~/Library/Application\ Support/CrashReporter/Adobe*
rm -rf ~/Library/Caches/Adobe
rm -rf ~/Library/Caches/com.Adobe.*
rm -rf ~/Library/Caches/com.adobe.*
rm -rf ~/Library/Cookies/com.adobe.*
sudo rm -rf ~/Library/Logs/Adobe*
rm -rf ~/Library/PhotoshopCrashes
sudo rm -rf ~/Library/Preferences/Adobe*
rm -rf ~/Library/Preferences/com.adobe.*
rm -rf ~/Library/Preferences/Macromedia*
rm -rf ~/Library/Saved\ Application\ State/com.adobe.*


echo "Finished cleaning up Adobe CC applications"
