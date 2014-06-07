from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
from httpinterface import *

CUSTOM_PORT = 4000
inter = interface()


class MyWebServer(BaseHTTPRequestHandler):
    """Handler for the GET requests"""
    def do_GET(self):
	filename = inter.extract_param(self.path.split("?&")[1])-1
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        # Send the html message
        print(str(filename)+".png")
        self.wfile.write(str(filename)+".png")
        return

""" Test - curl http://localhost:8888 """

if __name__ == "__main__":
    try:
        # Instantiate a HTTP Server
        server = HTTPServer(('', CUSTOM_PORT), MyWebServer)
        print 'Started httpserver on port ' , CUSTOM_PORT   
        # Wait forever for incoming htto requests
        server.serve_forever()
    except KeyboardInterrupt:
        print '^C received, shutting down the web server'
        server.socket.close()