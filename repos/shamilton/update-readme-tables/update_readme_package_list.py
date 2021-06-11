from argparse import ArgumentParser, FileType
from json import load
import re
from pandas import DataFrame
from pprint import pprint
import sys

def derivations_to_dataframe(derivations):
    new_dict = {'name':[], 'attribute path':[], 'description':[]}
    for drv in derivations:
        new_dict['name'].append(drv['name'])
        new_dict['attribute path'].append(drv['attribute'])
        new_dict['description'].append(drv['description'].replace('\n', ' '))
    return DataFrame.from_dict(new_dict)


parser = ArgumentParser()
parser.add_argument('packages_list', type=FileType('r'),
                         default=sys.stdin)
args = parser.parse_args()
derivations = load(args.packages_list)
table = derivations_to_dataframe(derivations).to_markdown(index=False)

def new_readme_with_package_list():
    readme_content = open('README.md', 'r').read()
    new_readme_content = re.sub(r'(<!-- PACKAGE_LIST_START -->\n)(?:.*\n)*(<!-- PACKAGE_LIST_END -->)',
                                r'\1'+table+r'\n\2',
                                readme_content)
    return new_readme_content

new_readme = new_readme_with_package_list()
with open('README.md', 'w') as readme:
    readme.write(new_readme)
