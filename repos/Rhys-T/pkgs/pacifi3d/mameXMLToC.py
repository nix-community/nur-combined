#!/usr/bin/env python3
import xml.etree.ElementTree as ET
import sys
el: ET.Element
baseSets = ('puckman', 'pacman')
loadTmpl = R'''
#line 8 "mameXMLToC.py"
    if (!strcmp(name,{name})) {{
      printf({loading});
      {roms}
#line 12 "mameXMLToC.py"
      return;
    }}
'''
loadROMTmpl = '''
#line 17 "mameXMLToC.py"
      rom_load({file}, {offset:#04x}, {size:#04x}, {region}, {crc32:#08x});
'''
listTmpl = '''
#line 21 "mameXMLToC.py"
    printf({indentName});
'''
loads = []
lists = []
def cStr(x):
	return '"' + x.replace('\n', '\\n') + '"' # TODO escape properly
for event, el in ET.iterparse(sys.argv[1]):
	name = el.get('name')
	parent = el.get('cloneof')
	if el.tag != 'machine' or el.get('isdevice') == 'yes' or (parent or name) not in baseSets:
		continue
	desc = el.find('description').text
	roms = []
	for romEl in el.findall('rom'):
		romFile = romEl.get('name')
		if romEl.get('merge', romFile) != romFile:
			ET.dump(el)
			raise ValueError()
		offset = int(romEl.get('offset'), 16)
		size = int(romEl.get('size'), 16)
		mameRegion = romEl.get('region')
		if mameRegion == 'maincpu':
			region = 'memory'
		elif mameRegion == 'gfx1':
			if offset >= 0x1000:
				offset -= 0x1000
				region = 'spriterom'
			else:
				region = 'tilerom'
		elif mameRegion == 'proms':
			region = 'prom'
		elif mameRegion == 'namco':
			region = 'soundprom'
		else:
			raise ValueError(mameRegion)
		crc32 = int(romEl.get('crc'), 16)
		roms.append(dict(
			file = cStr(romFile),
			offset = offset,
			size = size,
			region = region,
			crc32 = crc32,
		))
	loads.append(loadTmpl.format(
		name = cStr(name),
		parent = cStr(parent) if parent else "0",
		loading = cStr(f'Loading {desc}\n'),
		roms = ''.join(loadROMTmpl.format(**rom) for rom in roms),
	))
	lists.append(listTmpl.format(
		indentName = cStr(f'  {name}\n'),
	))
with open(sys.argv[2], 'w') as f:
	for l in loads:
		print(l, file=f)
with open(sys.argv[3], 'w') as f:
	for l in lists:
		print(l, file=f)
	