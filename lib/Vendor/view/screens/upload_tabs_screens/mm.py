from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding

import base64
import os

# Provided ciphertext and secret key
cipher_text = "NUOzPjZtBK+V8iuaHLe/PN1vCk/UxyJvtWpkvM3UqY0ZKPsJVBsrRD/eeDn2XFCI"
secret_key = "SYePwhRJHhPG8S6c"

# Decode the ciphertext and secret key from base64
cipher_text_bytes = base64.b64decode(cipher_text)
secret_key_bytes = secret_key.encode("utf-8")

# Create a cipher object with AES algorithm and ECB mode
cipher = Cipher(algorithms.AES(secret_key_bytes), modes.ECB(), backend=default_backend())

# Create a decryptor
decryptor = cipher.decryptor()

# Decrypt the ciphertext
decrypted_data = decryptor.update(cipher_text_bytes) + decryptor.finalize()

# Print the decrypted data as a UTF-8 string
print("Decrypted:", decrypted_data.decode("utf-8"))
