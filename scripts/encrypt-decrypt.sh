#!/bin/bash
# Script to encrypt and decrypt a file using OpenSSL with PBKDF2

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
  echo "OpenSSL is not installed. Please install it and try again."
  exit 1
fi

while true; do
  echo "Select an option:"
  echo " 1 - Encrypt file"
  echo " 2 - Decrypt file"
  echo " 0 - Exit"

  read -p "Enter your choice: " choice

  case $choice in
    1)
      # Encryption process
      read -p "Enter the path to the file you want to encrypt: " FILE

      if [ ! -f "$FILE" ]; then
        echo "File not found!"
        continue
      fi

      read -s -p "Enter a password for encryption: " PASSWORD
      echo
      read -s -p "Confirm the password: " PASSWORD_CONFIRM
      echo

      if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
        echo "Passwords do not match. Try again."
        continue
      fi

      ENCRYPTED_FILE="${FILE}.enc"
      openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$FILE" -out "$ENCRYPTED_FILE" -pass pass:"$PASSWORD"

      if [ $? -eq 0 ]; then
        echo "File encrypted successfully as $ENCRYPTED_FILE"
      else
        echo "Encryption failed."
      fi
      ;;
      
    2)
      # Decryption process
      read -p "Enter the path to the file you want to decrypt: " ENCRYPTED_FILE

      if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "Encrypted file not found!"
        continue
      fi

      read -p "Enter the output filename for decrypted content: " DECRYPTED_FILE
      read -s -p "Enter the password for decryption: " PASSWORD
      echo

      openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" -pass pass:"$PASSWORD"

      if [ $? -eq 0 ]; then
        echo "File decrypted successfully as $DECRYPTED_FILE"
      else
        echo "Decryption failed. Please check the password and try again."
      fi
      ;;
    
    0)
      echo "Exiting!"
      exit 0
      ;;
    
    *)
      echo "Invalid option. Choose 1 for encrypt, 2 for decrypt, or 0 to exit."
      ;;
  esac
  echo ""
done
