from contextlib import contextmanager
import subprocess
import sys
import re


AUTH_URL_RE = re.compile(r'^https://keyhub\.wearespindle\.com/login/code\?usercode=[\w-]+$')


@contextmanager
def run(*args, **kwargs):
    """
    Spawn a subprocess and make sure to terminate (or kill) it when we
    (the parent) is done or an exception occurs.
    """
    p = subprocess.Popen(*args, **kwargs)
    try:
        yield p
    finally:
        p.terminate()
        p.kill()


def main():
    """
    Wraps the Keyhub CLI and captures the 'Authentication is required'
    message that will ask the user to open an URL in the browser.

    This script will open the URL with `xdg-open`, and remove the
    authentication header from the output. Output of keyhub can then
    reliably be used in automation tools.
    """
    with run(['keyhub'] + sys.argv[1:], stdout=subprocess.PIPE) as p:
        header = p.stdout.readline().decode('utf-8').rstrip()
        if header == 'Authentication is required':
            for line in p.stdout:
                url = line.decode('utf-8').rstrip()
                if AUTH_URL_RE.match(url):
                    subprocess.check_call(['xdg-open', url])
                    p.stdout.readline() # empty line
                    break
        else:
            print(header)

        for line in p.stdout:
            print(line.decode('utf-8').rstrip())

        p.communicate()
        exit(p.returncode)


if __name__ == '__main__':
    main()
