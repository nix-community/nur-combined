#!/usr/bin/python3
"""Exercise the real libical recurrence helper with synthetic cached events."""
import datetime as dt
import json
from pathlib import Path
import subprocess
from zoneinfo import ZoneInfo

project=Path(__file__).resolve().parents[1]
helper=project/'target/native/spotlight-freebusy'
UTC=dt.timezone.utc
def epoch(text,zone=UTC): return int(dt.datetime.fromisoformat(text).replace(tzinfo=zone).timestamp())
def event(uid,body): return f'BEGIN:VEVENT\r\nUID:{uid}\r\n{body}\r\nEND:VEVENT\r\n'
def expand(events,start='2027-07-13',days=7,zone='Australia/Sydney',fail=False):
    payload='BEGIN:VCALENDAR\r\nVERSION:2.0\r\n'+''.join(events)+'END:VCALENDAR\r\n'
    req={'items':[{'payload':payload,'collection':'Fixture calendar'}], 'start':epoch(start), 'end':epoch(start)+days*86400,'timezone':zone}
    result=subprocess.run([str(helper)],input=json.dumps(req),text=True,capture_output=True,timeout=8)
    if fail:
        assert result.returncode!=0
        return
    assert result.returncode==0,result.stderr
    return sorted(tuple(span) for span in json.loads(result.stdout)['busy'])

master=event('repeat','DTSTART:20270713T130000Z\r\nDTEND:20270713T140000Z\r\nRRULE:FREQ=DAILY;COUNT=3')
base=epoch('2027-07-13T13:00')
expected=[(base+i*86400,base+i*86400+3600) for i in range(3)]
assert expand([master])==expected
exdate=master.replace('RRULE:', 'EXDATE:20270714T130000Z\r\nRRULE:')
assert expand([exdate])==[expected[0],expected[2]]
moved=event('repeat','RECURRENCE-ID:20270714T130000Z\r\nDTSTART:20270714T150000Z\r\nDTEND:20270714T160000Z')
assert expand([master,moved])==sorted([expected[0],expected[2],(base+86400+7200,base+86400+10800)])
cancel=event('repeat','RECURRENCE-ID:20270714T130000Z\r\nSTATUS:CANCELLED')
assert expand([master,cancel])==[expected[0],expected[2]]
transparent=master.replace('UID:repeat','UID:transparent').replace('DTSTART:', 'TRANSP:TRANSPARENT\r\nDTSTART:')
assert expand([transparent])==[]
assert expand([master.replace('DTSTART:', 'STATUS:CANCELLED\r\nDTSTART:')])==[]
floating=event('floating','DTSTART:20270713T090000\r\nDTEND:20270713T100000')
sydney=ZoneInfo('Australia/Sydney')
assert expand([floating],start='2027-07-12')==[(epoch('2027-07-13T09:00',sydney),epoch('2027-07-13T10:00',sydney))]
zoned=event('zoned','DTSTART;TZID=Australia/Sydney:20270713T090000\r\nDTEND;TZID=Australia/Sydney:20270713T100000')
assert expand([zoned],start='2027-07-12')==expand([floating],start='2027-07-12')
all_day=event('all-day','DTSTART;VALUE=DATE:20271002\r\nDTEND;VALUE=DATE:20271004')
assert expand([all_day],start='2027-10-01')==[(epoch('2027-10-02',sydney),epoch('2027-10-04',sydney))]
expand([event('bad-zone','DTSTART;TZID=Not/AZone:20270713T090000\r\nDTEND;TZID=Not/AZone:20270713T100000')],fail=True)
expand([moved.replace('RECURRENCE-ID:', 'RECURRENCE-ID;RANGE=THISANDFUTURE:')],fail=True)
expand([master,master],fail=True)
expand([moved],fail=True)
recurring_day=event('recurring-day','DTSTART;VALUE=DATE:20271002\r\nDTEND;VALUE=DATE:20271003\r\nRRULE:FREQ=DAILY;COUNT=3')
assert expand([recurring_day],start='2027-10-01')==[(epoch(f'2027-10-0{i}',sydney),epoch(f'2027-10-0{i+1}',sydney)) for i in range(2,5)]
print('Real libical checks passed: recurrence, EXDATE, moved/cancelled instances, transparency, floating/TZID dates, all-day DST, and incomplete/unsupported input rejection.')
