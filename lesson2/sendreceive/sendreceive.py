import time
import socket
import sys


ERRNO_SOCKET_NOT_CONNECTED = 57
ERRNO_SOCKET_CONNECTION_REFUSED = 61

ARGS = sys.argv[1:]

DEFAULT_IP = '127.0.0.1'
DEFAULT_PORT = 19000


def send(filename, ip=DEFAULT_IP, port=DEFAULT_PORT):
    while True:
        print "Sending file %s to %s:%d" % (filename, ip, port)

        while True:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.connect((ip, port))
            except socket.error as e:
                if e.errno == ERRNO_SOCKET_CONNECTION_REFUSED:
                    sock.close()
                    time.sleep(2.0)
                    print "Retrying..."
                else:
                    raise
            else:
                print "Connected..."
                break

        try:
            # time.sleep(0.5)
            print "Sending file..."
            with open(filename) as f:
                sock.send(f.read())
        finally:
            print "File sent."
            # time.sleep(1.0)
            sock.close()


def receive(ip=DEFAULT_IP, port=DEFAULT_PORT):
    print "Waiting for incoming file..."
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind((ip, port))
    sock.listen(1)

    conn = None

    try:
        while True:
            conn, addr = sock.accept()
            print "Accepted connection: %r from %r" % (conn, addr)
            # time.sleep(0.5)
            num_bytes_received = 0
            while True:
                data = conn.recv(1024)
                num_bytes_received += len(data)
                if len(data) < 1024:
                    print "Transmission complete."
                    break

            print "Received %d bytes" % num_bytes_received
    except KeyboardInterrupt:
        pass
    finally:
        print "Terminating..."
        try:
            if conn:
                conn.close()
            sock.shutdown(socket.SHUT_RDWR)
        except socket.error as e:
            if e.errno == ERRNO_SOCKET_NOT_CONNECTED:
                pass
            else:
                raise


command = ARGS.pop(0)
if command not in ('send', 'receive'):
    print "Invalid command:", command
    sys.exit(1)

print "Starting command", command

if command == 'send':
    if not 1 <= len(ARGS) <= 2:
        print "Usage: send <file> [<ip:port>]"
        sys.exit(1)
    else:
        filename = ARGS[0]
        if len(ARGS) == 2:
            ip_and_port = ARGS[1]
            ip, port = ip_and_port.split(':')
            port = int(port)
            send(filename, ip, port)
        else:
            send(filename)
else:
    receive()
