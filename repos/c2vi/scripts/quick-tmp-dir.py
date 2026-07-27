
import sys
import os
import shutil


banned_names = []

topdir = os.environ["TOPDIR"]
if topdir.endswith("/"):
    topdir = topdir[0:-1]

pwd = os.getcwd()

chars_right = {
        "index" : "rfvbgt",
        "middle": "ed",
        "ring": "ws",
        "pinky": "",
}

chars_left = {
        "index" : "hnzujm",
        "middle": "ik",
        "ring": "lo",
        "pinky": "dp",
}

chars_as_list = list(chars_right.values()) + list(chars_left.values())

listing = os.listdir(topdir)

def check(name):
    #print("######## name:", name)
    chose_this_name = True
    for item in listing:
        if item.startswith(name):
            chose_this_name = False
            break;
    if chose_this_name:
        path = topdir + "/" + name
        os.mkdir(path) 
        print("Created tmpdir at:", path, file=sys.stderr)
        print(path, end="")
        exit()

# if arg1 is "c" ... clear all empty dirs in topdir
try:
    tmp = sys.argv[1]
except:
    tmp = ""
if tmp == "c":
    print("Removing all empty tmp-dirs", file=sys.stderr)
    tmpdirs = os.listdir(topdir)
    #print("tmpdirs...", tmpdirs, file=sys.stderr)
    for el in tmpdirs:
        path = topdir + "/" + el
        if os.listdir(path) == []:
            print("- removing...", path, file=sys.stderr)
            os.rmdir(path)

    # exit without cd'ing anywhere
    print(pwd, end="")
    exit()





# if we are in a sub dir of topdir
# we want to rename the current tmpdir to argv[1]
if pwd.startswith(topdir):
    name = ""
    for arg in sys.argv[1:]:
        name += "_" + arg
    if name == "":
        print("Would rename, but no name given as argv[1]", file=sys.stderr)
        # exit without cd'ing anywhere
        print(pwd, end="")
        exit()

    name = name[1:]

    len_topdir = len(topdir.split("/"))
    old_arr = pwd.split("/")[0:len_topdir +1]

    old = "/".join(old_arr)
    new = topdir + "/" + name
    
    print("Renaming", old, "to", new)
    shutil.move(old, new)
    print(new, end="")
    exit()
    
    # exit without cd'ing anywhere
    print(pwd, end="")
    exit()







for finger_one in chars_as_list:
    for finger_two in chars_as_list:
        if finger_one is not finger_two:
            for char_one in finger_one:
                for char_two in finger_two:
                    if char_one is not char_two:
                        name = char_one + char_two
                        if name not in banned_names:
                            check(name)



