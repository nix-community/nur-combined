
import hashlib
import datetime
import sys
from cryptography.fernet import Fernet
import os
import json
import base64
import subprocess
import time
import psutil

YT_TIME_MAX = 60 # in min
STATE_FILE = "/etc/yt_block_state"

DEFAULT_STATE = {
        "yt_time_left": 0,
        "yt_time_current": 0,
        "date": "2024-07-15",
}

YT_HOSTS = [
    [ "127.0.0.1", "youtube.com" ],
    [ "127.0.0.1", "www.youtube.com" ],
    [ "::1", "www.youtube.com" ],
    [ "::1", "youtube.com" ],
]

def main():
    if sys.argv[1] == "g" or sys.argv[1] == "guard":
        cmd_guard()
        return

    if sys.argv[1] == "r" or sys.argv[1] == "request":
        cmd_request()
        return

    if sys.argv[1] == "i" or sys.argv[1] == "info":
        cmd_info()
        return

    if sys.argv[1] == "s" or sys.argv[1] == "starter":
        cmd_starter()
        return
    
    print("unknown command!!!!")
    

def cmd_guard():
    pwd = get_pwd()

    state = read_state(pwd)

    # if it's after 22:00 block yt and kill all minecraft processes
    now = datetime.datetime.now()
    if now.hour >= 21:
        print("after 21:00 blocking....")
        block_yt()
        kill_mc()
        return

    # if date is not today, set time_left to YT_TIME_LIMIT
    date_from_state = datetime.datetime.strptime(state["date"], "%Y-%m-%d")
    if now.date() != date_from_state.date():
        state["yt_time_left"] = YT_TIME_MAX
        state["date"] = now.strftime("%Y-%m-%d")


    # if time_current in state is 0, block yt
    if state["yt_time_current"] == 0:
        block_yt()

    # if time_current in state is greater than 0, unblock yt
    if state["yt_time_current"] > 0:
        unblock_yt()

    # decrement time_current
    if state["yt_time_current"] > 0:
        state["yt_time_current"] -= 1

    write_state(state, pwd)

    # so that i can't just change the time in order to watch after 21:00
    os.system("systemctl start systemd-timesyncd")

def cmd_request():
    pwd = get_pwd()

    state = read_state(pwd)

    time_to_request = int(sys.argv[2])

    if time_to_request > state["yt_time_left"]:
        print("Trying to request more time, than is left")
        exit(1)

    state["yt_time_left"] -= time_to_request
    state["yt_time_current"] = time_to_request +1 # +1 because we are running guard now as well....

    write_state(state, pwd)

    # run gurad now as well ... so that changes take effect immediately
    cmd_guard()


def cmd_info():
    pwd = get_pwd()

    state = read_state(pwd)

    print("YouTube")
    print("time_left:", state["yt_time_left"])
    print("time_current:", state["yt_time_current"])




def get_pwd():
    with open("/etc/machine-id", "r") as f:
        pwd = f.read()


    for i in range(0, 7):
        my_string_bits = pwd.encode('utf-8')
        secret_thing = hashlib.sha256(my_string_bits)
        pwd = secret_thing.hexdigest()

    pwd = pwd[0:32]
    pwd_bytes =pwd.encode('ascii')
    pwd_base64_bytes = base64.b64encode(pwd_bytes)
    return pwd_base64_bytes


def read_state(pwd):
    fernet = Fernet(pwd)

    if not os.path.exists(STATE_FILE):
        with open(STATE_FILE, "wb") as file:
            encrypted = fernet.encrypt(json.dumps(DEFAULT_STATE).encode())
            file.write(encrypted)

        return DEFAULT_STATE

    with open(STATE_FILE, "rb") as file:
        state_encrypted = file.read()
        state_string = fernet.decrypt(state_encrypted)
        state = json.loads(state_string)

    return state


def write_state(state, pwd):
    fernet = Fernet(pwd)

    with open(STATE_FILE, "wb") as file:
        state_string = json.dumps(state)
        state_encrypted = fernet.encrypt(state_string.encode())
        file.write(state_encrypted)


def get_hosts():
    with open(f"/etc/hosts", "r") as file:
        hosts = []
        for line in file.readlines():
            if line == "\n":
                continue
            split = line.split(" ")
            try:
                hosts.append([split[0].strip(), split[1].strip()])
            except:
                print("error with geting hosts from /etc/hosts: ", split)
    return hosts


def write_hosts(hosts):
    os.system("rm -rf /etc/hosts")
    with open("/etc/hosts", "w") as file:
        lines = []
        for entry in hosts:
            lines.append(entry[0] + " " + entry[1])

        file.write("\n".join(lines) + "\n")


def block_yt():
    hosts = get_hosts()
    for entry in YT_HOSTS:
        if entry not in hosts:
            hosts.append(entry)

    write_hosts(hosts)
    yt_ips = [
        "142.251.208.174",
        "142.251.208.142",
        "142.251.208.110",
        "142.251.39.78",
        "142.251.39.46",
        "142.251.39.14",
        "142.250.201.206",
        "142.250.180.238",
        "142.250.180.206",
        "172.217.20.14",
        "172.217.19.110",

        "188.21.9.20",
        "142.251.208.142",

        # "2a00:1450:400d:80d::200e",
        # "2a00:1450:400d:80c::200e",
        # "2a00:1450:400d:802::200e",
        # "2a00:1450:400d:80e::200e",
    ]

    os.system("iptables -N YTBLOCK")
    print("running: iptables -N YTBLOCK")

    os.system("iptables -D OUTPUT -j YTBLOCK")
    os.system("iptables -I OUTPUT -j YTBLOCK")
    os.system("iptables -I INPUT -d 188.21.9.20 -j REJECT")
    print("running: iptables -I OUTPUT -j YTBLOCK")

    for ip in yt_ips:
        os.system(f"iptables -D YTBLOCK -d {ip} -j REJECT")
        os.system(f"iptables -I YTBLOCK -d {ip} -j REJECT")
        print(f"running: iptables -I YTBLOCK -d {ip} -j REJECT")
    #os.system("iptables -I OUTPUT -d  -j REJECT")

def unblock_yt():
    hosts = get_hosts()
    new_hosts = []
    for entry in hosts:
        if entry[1] == "youtube.com" or entry[1] == "www.youtube.com":
            continue
        else:
            new_hosts.append(entry)

    write_hosts(new_hosts)
    os.system("iptables -F YTBLOCK")
    print("running: iptables -F YTBLOCK")

    os.system("iptables -D OUTPUT -j YTBLOCK")
    os.system("iptables -D OUTPUT -j YTBLOCK")
    os.system("iptables -D OUTPUT -j YTBLOCK")
    os.system("iptables -D INPUT -d 188.21.9.20 -j REJECT")
    print("running 3 times: iptables -D OUTPUT -j YTBLOCK")

    os.system("iptables -X YTBLOCK")
    print("running: iptables -X YTBLOCK")

def kill_mc():
    for proc in psutil.process_iter():
        if "org.prismlauncher.EntryPoint" in proc.cmdline():
            os.system(f"kill {proc.pid}")

def kill_line(line):
    print("line:", line)
    pid = int(line.split(" ")[0])
    print("killing pid:", pid)
    os.system(f"kill {pid}")

def cmd_starter():
    # become a unkillable process and start this pyhton file with arg1=guard every minute
    print("cmd starter.... what tf is going on hereeeeeeeeeeeee")

    # make the /dev/unkillable
    os.system("rm /dev/unkillable")
    os.system("mknod /dev/unkillable c 117 0")
    os.system("chmod 666 /dev/unkillable")
    os.system("ls /dev/unkillable")

    # get pid
    pid = os.getpid()
    print("starter process running with pid", pid)

    #os.system(f"$READ_HELPER {}", pid)
    # for some strange reason this does not work
    with open("/dev/unkillable", "w") as file:
        file.write(str(pid))
        #pass

    while True:
        print("file:", __file__)
        os.system(f"$PYTHON {__file__} guard")
        time.sleep(60*5)

if __name__ == "__main__":
    main()
