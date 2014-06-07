import socket
import sys
import thread
import time

def handle(s):
    data = repr(s.recv(4096))
    if(data.find("?") < 1):
        s.close()
        return 0 
    p = data.split("?")
    for a in range(0,len(p)-1):
	print p[a]
    s.send('''
    HTTP/1.1 101 Web Socket Protocol Handshake\r
    Upgrade: WebSocket\r
    Connection: Upgrade\r
    WebSocket-Origin: http://localhost:8888\r
    WebSocket-Location: ws://localhost:4000/\r
    WebSocket-Protocol: sample
    '''.strip() + '\r\n\r\n')
    s.send("Hello World")
    s.close()
    return 0

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# Bind the socket to the port
server_address = ('127.0.0.1', 4000)
print 'starting up on %s port %s' % server_address
sock.bind(server_address)

sock.listen(1)


while True:
    # Wait for a connection
    print 'waiting for a connection'
    connection, client_address = sock.accept()
    args = (connection,)
    thread.start_new_thread(handle, args)
