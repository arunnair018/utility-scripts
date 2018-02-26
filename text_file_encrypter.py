import base64, hashlib,sys
from cryptography.fernet import Fernet


try:
	password = sys.argv[3]
	key = hashlib.md5(password.encode()).hexdigest()
	key_64 = base64.urlsafe_b64encode(key.encode())

	if sys.argv[1]=='encrypt':
		with open(sys.argv[2],"r") as file:
			with open('ciphered','w+') as cfile:
				for line in file.readlines():
					line = Fernet(key_64).encrypt(line.encode())
					cfile.write(line.decode()+'\n')
		print('encrypted file: ciphered')

	if sys.argv[1]=='decrypt':
		with open(sys.argv[2],"r") as cfile:
			for line in cfile.readlines():
				line = Fernet(key_64).decrypt(line.encode())
				print(line.decode())	
except:
	print('Usage:\n\t',
		'encryption: python3 cipher.py encrypt filename password\n\t',
		'decryption: python3 cipher.py decrypt filename password\n')
