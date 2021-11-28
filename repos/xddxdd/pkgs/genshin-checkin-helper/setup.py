from pathlib import Path

from setuptools import find_packages, setup

long_description = Path('README.md').read_text(encoding='utf-8')


def load_requirements(filename):
    with Path(filename).open() as f:
        return [line.strip() for line in f if not line.startswith('#')]


setup(
    name='genshin-checkin-helper',
    version='1.0.3',
    packages=find_packages(),
    url='https://github.com/y1ndan/genshin-checkin-helper',
    license='MIT',
    author='y1ndan',
    author_email='y1nd4n@outlook.com',
    description='A Python library to send notifications to your iPhone, Discord, Telegram, WeChat, QQ and DingTalk.',
    long_description=long_description,
    long_description_content_type='text/markdown',
    include_package_data=True,
    data_files=['genshincheckinhelper/config/config.example.json'],
    install_requires=load_requirements('requirements.txt'),
    entry_points={
        'console_scripts': [
            'genshin-checkin-helper=genshincheckinhelper.main:main',
            'genshin-checkin-helper-once=genshincheckinhelper.main:run_once',
        ]
    },
    python_requires='>=3.6',
)
