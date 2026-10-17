import glob
import re

for d in ['app/src/main/res/drawable', 'android-stubs/src/main/resources/drawable']:
    for f in glob.glob(d + '/*.xml'):
        with open(f, 'r') as fp:
            txt = fp.read()
        txt = txt.replace('dip"', 'dp"').replace('dip<', 'dp<').replace('dip ', 'dp ')
        txt = txt.replace('@android:color/white', '#ffffffff')
        txt = txt.replace('@android:color/black', '#ff000000')
        txt = txt.replace('@android:color/transparent', '#00000000')
        txt = re.sub(r'@(?:android:)?color/[a-zA-Z0-9_]+', '#ffffffff', txt)
        with open(f, 'w') as fp:
            fp.write(txt)
