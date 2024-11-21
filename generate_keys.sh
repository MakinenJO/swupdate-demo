#!/bin/bash

#############################################
# RSA Key Generation
#############################################

# Generate file with password
echo mypassword > password

# Generate private key
openssl genrsa -aes256 -passout file:password -out priv.pem
# Generate public key
openssl rsa -in priv.pem -out public.pem -outform PEM -pubout -passin file:password


#############################################
# Encryption Key Generation
#############################################

# Create 32-byte key
key=`openssl rand -hex 32`
# Create 16-byte initialisation vector (iv)
ivt=`openssl rand -hex 16`

# printf $key > enc_key
# printf $ivt > enc_ivt
# Key & ivt in format for target (where swupdate is running):
printf "$key $ivt" > enc_key_target
# Key and ivt in format for swugenerator:
printf "key=$key\niv=$ivt" > enc_key_ivt