
filter=--exclude="./Forms"

# Geschichte
#echo "###################### Geschichte ######################"
#rclone copy -vv --exclude share-geschichte:Kursmaterialien/Forms share-geschichte:Kursmaterialien ~/work/htl/geschichte/class-materials/ 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/class-materials:    /'

# DE
echo "########################## DE ##########################"
rclone copy -vv $filter share-de-class-materials: ~/work/htl/de/class-materials/ 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/class-materials:    /'

# Labor
echo "########################## Labor ##########################"
rclone copy -vv $filter --exclude="ubuntu-22.04.3-desktop-amd64.iso" share-klotz-class-materials: ~/work/htl/labor/klotz/class-materials/ 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/class-materials:    /'



# HWE
#echo "########################## HWE #########################"
#rclone copy -vv $fliter share-hwe:Freigegebene\ Dokumente/General ~/work/htl/projekt/teams-documents/ 2>&1 >/dev/null | grep Copied --color=never  | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/teams-documents:    /'


#rclone copy -vv $filter share-hwe:Class\ Files/Assignments ~/work/htl/projekt/assignments-teams 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/assignments-teams:    /'

# DIC
echo "########################## DIC #########################"
rclone copy -vv $filter share-dic-teams-documents:General ~/work/htl/dic/teams-documents 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/teams-documents:    /'

rclone copy -vv $filter share-dic-class-materials: ~/work/htl/dic/class-materials 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/class-materials:    /'


# KSN
echo "########################## KSN #########################"
rclone copy -vv --exclude share-ksn-class-materials:Kursmaterialien/Forms $filter share-ksn-class-materials: ~/work/htl/ksn/class-materials 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/class-materials:    /'

# M
echo "########################### M ##########################"
rclone copy -vv $filter share-math-teams-documents:General ~/work/htl/math/teams-documents 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/teams-documents:    /'
rclone copy -vv $filter share-math-class-materials: ~/work/htl/math/class-materials 2>&1 >/dev/null | grep Copied --color=never | awk -F':' '{print $4}' | cut -c 2- | sed 's/^/class-materials:    /'
