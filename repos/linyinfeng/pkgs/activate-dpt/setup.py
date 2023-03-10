from setuptools import setup

setup(
    name="activate-dpt",
    version="0.1",
    description="Activate dpt usb ethernet",
    author="Lin Yinfeng",
    author_email="lin.yinfeng@outlook.com",
    scripts=["activate-dpt.py"],
    requires=["pyserial"],
)
