import time, sys
from apns import APNs, Frame, Payload

apns = APNs(use_sandbox=True, cert_file='Push_hck.ghost.v1.pem',key_file='Devkey_hck.ghost.v1.pem')

def send_notification(token_hex,message):
    payload = Payload(alert=message, sound='default', badge=1)
    apns.gateway_server.send_notification(token_hex,payload)

def main(argv):
    send_notification(argv[1],argv[2])

if __name__ == '__main__':
    main(sys.argv)
