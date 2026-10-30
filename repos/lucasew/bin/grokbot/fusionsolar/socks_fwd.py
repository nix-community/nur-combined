#!/usr/bin/env python3
# usage: socks_fwd.py LPORT DHOST DPORT [SOCKS_PORT]
import socket,struct,sys,threading
lp,dh,dp=int(sys.argv[1]),sys.argv[2],int(sys.argv[3]); sp=int(sys.argv[4]) if len(sys.argv)>4 else 1055
def pipe(a,b):
    try:
        while (d:=a.recv(65536)): b.sendall(d)
    except OSError: pass
    finally:
        for x in (a,b):
            try: x.shutdown(socket.SHUT_RDWR)
            except OSError: pass
def handle(c):
    s=socket.create_connection(("127.0.0.1",sp))
    s.sendall(b"\x05\x01\x00"); s.recv(2)
    h=dh.encode(); s.sendall(b"\x05\x01\x00\x03"+bytes([len(h)])+h+struct.pack(">H",dp))
    r=s.recv(10)
    if len(r)<2 or r[1]!=0: c.close(); s.close(); return
    threading.Thread(target=pipe,args=(c,s),daemon=True).start(); pipe(s,c)
l=socket.socket(); l.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1); l.bind(("127.0.0.1",lp)); l.listen(64)
while True:
    c,_=l.accept(); threading.Thread(target=handle,args=(c,),daemon=True).start()
