
print("hiiiiiiiiiiiiiiiiiiiii:")

#import sys
import os


#path = input("path: ")
path = "/proc/2767310/fd/0"
print("path:", path)

#os.system(f"cat {path}")
#print("hi:", os.path.abspath(sys.stdin.name))
print("my stdin:", os.readlink('/proc/self/fd/0'))
print("lf stdin:", os.readlink(path))

#os.system(f"cat /dev/pts/16")
#os.system("stty -F /proc/2763309/fd/0 -raw -icanon -echo; cat /proc/2763309/fd/0 > /home/me/p2")
exit()

try:
    file = open(path, "r")

    print(f"before path: {path}\n")
    print(f"before path: {file}\n")

    b = file.read(1)

    print("got: " + b + "\n")

    file.close()
except Exception as e:
    print("ERROR: " + str(e) + "\n")
