
import shlex
from pathlib import Path
from os import path
import os
import argparse
import sys, tty, termios
import subprocess
import signal

DB_FILE = "/home/me/work/config/scripts/nav/db"


def main():
    pwd = Path(os.getcwd())
    db_matches = get_db_matches(pwd, DB_FILE)
    folder_db_matches = get_folder_db_matches(pwd)
    folder_matches = get_folder_matches(pwd)

    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--mode', help='mode of the program', type=str)
    args = parser.parse_args()

    if args.mode == "lf":

        cmd = "ps" # | grep lf | awk '{print $1}'"
        cmd2 = "ps | grep lf | awk '{print $1}'"
        #p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)

        #result = subprocess.run(cmd2, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        #pid = result.stdout.decode('utf-8').strip()

        #print("hiiiiiiiiii:", b)
        #a = p.stdout.readlines()
        #a = subprocess.check_output(["ps"]).decode("utf-8")

        #a = input("hello --" + f"/proc/{pid}/fd/0" + "--")

        #signal.signal(signal)

        out = open("/home/me/p1", "w")
        sys.stdout = out
        sys.stderr = out


        path = "/proc/2778149/fd/0"

        print("my stdin:", os.readlink('/proc/self/fd/0'))
        print("lf stdin:", os.readlink(path))
        print("pid:", os.getpid())
        input()
        print("after first input")

        file = open("/dev/pts/16", "r")
        os.setpgid(os.getpid(), 2778149)

        subprocess.run(["ps", "-j"], stdout=out, stderr=out)

        exec("file.read(1)")
        #file.read(1)

        a = input()
        print("input was:", a)

        out.close()
        file.close()

        exit()

        #out.write("test" + pid + "\n")
        out.flush()

        #path = f"/proc/{pid}/fd/0"


        out.write(f"before path: {path}\n")
        out.flush()

        os.system("echo from echo $SHELL > /home/me/p2")
        #os.system("/bin/bash /home/me/work/config/scripts/nav/run.sh 2>/home/me/p2 1>/home/me/p2")
        os.system(f"python /home/me/work/config/scripts/nav/test.py </home/me/test/file 2>/home/me/p2 1>/home/me/p2")

        #os.system(f"cat {path}")
        #old_settings = termios.tcgetattr(fd)

        try:

            file = open(path, "r")
            tty.setraw(file.fileno())

            out.write(f"before path: {file}\n")
            out.flush()

            b = file.read(1)

            out.write("got: " + b + "\n")
            out.flush()

            file.close()
        except e:
            out.write("ERROR: " + str(e) + "\n")

            #while True:
                #b = file.read(1)
                #out.write("got: " + b + "\n")

        out.close()


        """
        while True:
            fd = sys.stdin.fileno()
            print("fd", fd)
            old_settings = termios.tcgetattr(fd)
            try:
                tty.setraw(sys.stdin.fileno())
                ch = sys.stdin.read(1)
            finally:
                termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
            if ch == "q":
                break
            print("hello: ", ch)
        """

        #os.system("echo hello-world")
        #while True:
        #print("test", a)
        #input()
        #input("end: ")


    else:
        print("test", my_resolve("~"))
        print("db:", db_matches)
        print("folder db:", folder_db_matches)
        print("folder:", folder_matches)


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

def get_folder_matches(directory):
    matches = []
    ls = os.listdir(directory)

    for path in ls:
        if path[0] == ".":
            path_as_list = list(str(path))
            path_as_list.pop(0)
            path = "".join(path_as_list)


    return matches

def get_folder_db_matches(directory):
    if os.path.exists(directory / ".nav_db"):
        return get_db_matches(directory, directory / ".nav_db")
    else:
        return []

def my_resolve(path):
    if path == ".":
        return Path(os.getcwd())
    if str(path)[0] == "~":
        path_as_list = list(str(path))
        path_as_list.pop(0)
        return Path(str(Path.home()) + "".join(path_as_list))

    return path.resolve()


if __name__ == "__main__":
    main()

