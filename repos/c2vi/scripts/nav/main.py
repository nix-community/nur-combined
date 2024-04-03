
import shlex
from pathlib import Path
from os import path
import os
import argparse
import sys, tty, termios
import subprocess
from subprocess import Popen
import signal

DB_FILE = "/home/me/work/config/scripts/nav/db"

def debug(*args, **kargs):
    global out
    print(*args, **kargs, file=out)
    out.flush()

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--mode', help='mode of the program', type=str)
    parser.add_argument('-c', '--char', help='mode of the program', type=str)
    args = parser.parse_args()

    if args.mode == "lf":
        pre_cd = None
        lf_id = os.environ["id"]
        pwd = Path(os.getcwd())
        if args.char is not None:
            dests = do_nav(args.char, pwd)
            if len(dests) == 1:
                pre_cd = my_resolve(dests[0], pwd=pwd)
                pwd = pre_cd

        Popen(["lf", "-remote", f"send {lf_id} echo -- NAV --"])

        # for debug
        global out
        #out = open("/home/me/p1", "w")
        #sys.stderr = out
        #sys.stdout = out
        #debug()

        pid_lf = int(os.environ["lf_user_pid"])
        pgid = int(os.environ["lf_user_pgid"])

        #for debug
        #print("pid_lf", pid_lf)
        #print("pgid", pgid)

        path = f"/proc/{pid_lf}/fd/0"

        os.setpgid(os.getpid(), pgid)

        file = open(path, "r")

        #clear filter
        #os.system(f'lf -remote "send $id setfilter"')
        #os.system('lf -remote "send $id echo -- NAV --"')

        chars = []
        while True:
            print("-- HIIIIIIIIIII --")
            #Popen(["lf", "-remote", f"send {lf_id} echo -- NAV iiiiiiiiiiiiiiii --"])

            c = file.read(1)
            #debug("-- HIIIIIIIIIII after --")

            if pre_cd is not None:
                Popen(["lf", "-remote", f"send {lf_id} cd {pre_cd}"])
                pre_cd = None

            if c == "\x20" or c == "\x1b": # exit nav mode, when space or ESC is pressed
                if len(chars) == 0:
                    pass
                    Popen(["lf", "-remote", f"send {lf_id} setfilter"])
                    Popen(["lf", "-remote", f"send {lf_id} echo NAV Done"])
                print("NAV Done")
                break

            if c == "\x03":
                chars = chars[0:len(chars)-1]

            chars.append(c)

            dests = do_nav(chars, pwd)

            #for debug
            #debug("dests:", dests)

            if len(dests) == 1:
                path_to_go = my_resolve(dests[0], pwd=pwd)
                Popen(["lf", "-remote", f"send {lf_id} setfilter"])

                if os.path.isdir(path_to_go):
                    #for debug
                    #print("cding to:", path_to_go)

                    Popen(["lf", "-remote", f"send {lf_id} cd {path_to_go}"])
                    print("-- NAV --")
                    #Popen(["lf", "-remote", f"send {lf_id} echo -- NAV --"])
                else:
                    Popen(["lf", "-remote", f"send {lf_id} select {path_to_go}"])
                    Popen(["lf", "-remote", f"send {lf_id} echo NAV Done"])
                    break


                chars = []
                pwd = path_to_go

            elif len(dests) == 0:
                chars = []

            else:
                chars_as_string = "".join(chars)
                Popen(["lf", "-remote", f"send {lf_id} setfilter {chars_as_string}"])
                print("-- NAV --")
                #Popen(["lf", "-remote", f"send {lf_id} echo -- NAV --"])

            #debug("got:", c, "chars:", chars)

        file.close()

        # for debug
        out.close()


    else:
        chars = []
        while True:
            fd = sys.stdin.fileno()
            old_settings = termios.tcgetattr(fd)
            try:
                tty.setraw(sys.stdin.fileno())
                c = sys.stdin.read(1)
            finally:
                termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

            if c == "\x20" or c == "\x1b": # exit nav mode, when space or ESC is pressed
                break

            if c == "\x03":
                chars = chars[0:len(chars)-1]

            dests = do_nav(chars, pwd)

            if len(dests) == 1:
                path_to_go = my_resolve(dests[0], pwd=pwd)
                os.system("export")

            elif len(dests) == 0:
                pass

            else:
                pass

def do_nav(chars, pwd):
    db_matches = get_db_matches(pwd, DB_FILE)
    folder_db_matches = get_folder_db_matches(pwd)
    folder_items = list_folder(pwd)

    # for debug
    #print("pwd:", pwd)
    #print("chars:", chars)

    # first check if the char matches in what is in the main db
    # immediatly cd (return list with one el) if found
    for (match, dest) in db_matches:
        if match == chars[0]:
            return [dest]

    # next check local db
    # but also immediatly cd when found
    for (match, dest) in folder_db_matches:
        if match == chars[0]:
            return [dest]

    # then check folder contents
    # and return all that start with that char
    dests = []
    for item in folder_items:
        item_chars = item[0:len(chars)]
        search_chars = "".join(chars[0:len(chars)])
        if item_chars == search_chars:
            dests.append(item)
    return dests


def get_db_matches(directory, db_file):
    matches = []
    with open(db_file, "r") as file:
        for line in file.readlines():
            line = line.strip()
            if line == "":
                continue
            tmp = shlex.split(line)
            try:
                dir_in = tmp[0]
                shortcut = tmp[1]
                dest = tmp[2]
            except:
                eprint("db parse error on:", line)
                continue

            if dir_in == "*":
                matches.append((shortcut, dest))

            elif my_resolve(directory) == my_resolve(dir_in):
                matches.append((shortcut, dest))

    return matches

def list_folder(directory):
    matches = []
    ls = os.listdir(directory)

    """
    for path in ls:
        if path[0] == ".":
            path_as_list = list(str(path))
            path_as_list.pop(0)
            path = "".join(path_as_list)

        matches.append(path)
    """

    return ls

def get_folder_db_matches(directory):
    if os.path.exists(directory / ".nav_db"):
        return get_db_matches(directory, directory / ".nav_db")
    else:
        return []

def my_resolve(path, pwd=os.getcwd()):
    if path == ".":
        return Path(pwd)

    elif str(path)[0] == "~":
        path_as_list = list(str(path))
        path_as_list.pop(0)
        return Path(str(Path.home()) + "".join(path_as_list))

    elif str(path)[0] == "/":
        return Path(path)

    else:
        return Path(pwd) / Path(path)



if __name__ == "__main__":
    main()

