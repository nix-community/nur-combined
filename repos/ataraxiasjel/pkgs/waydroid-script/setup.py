from setuptools import setup

setup(
    name='@pname@',
    version='@version@',
    description='@desc@',
    packages=["main", "stuffs", "tools"],
    python_requires='>=3.8',
    install_requires = ['tqdm', 'requests'],
    package_dir = {
        'main': '.',
    },
    entry_points = {
        'console_scripts': ['waydroid-script=main.main:main'],
    }
)