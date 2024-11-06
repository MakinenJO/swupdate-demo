# SWUpdate Demo

## SWUpdate containerized setup

### Build and run container
```bash
docker build -t swupdate .
docker run -it --rm -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock swupdate
```

### Configure and build swupdate
```bash
cd swupdate
make menuconfig
make

# Run web server
./swupdate -w "--document-root examples/www/v2"
# Web interface should now be available at localhost:8080
# You can drop an .swu file here to update the target

# Useful options:
# -k <pubkey>      | pass public key for image verification
# -K <key_file>    | pass aes keyfile for decrypting encrypted images
# -l loglevel      | 0-4, higher level = more detail
# -i <swufile>     | pass swu package directly
# -c -i <swufile>  | check with swupdate if image file is valid

```

## Generate swupdate packages

### Install SWUGenerator tool
```bash
# Clone and build swugenerator tool
git clone https://github.com/sbabic/swugenerator.git
cd swugenerator
pip install .

# Add package location to PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Encrypt and decrypt files manually

```bash
# To encrypt files (key and iv must be passed as string)
openssl enc -aes-256-cbc -in files/testfile -out out/testfile.enc -K $(cat enc_key) -iv $(cat enc_ivt)
# To decrypt, add -d flag
openssl enc -aes-256-cbc -d -in out/testfile.enc -out out/testfile -K $(cat enc_key) -iv $(cat enc_ivt)
```


## Inspect swupdate package contents

The swupdate package is a cpio archive. You can extract it to view the contents with the following command
```bash
# out is the directory name where contents are extracted
# test.swu is the swupdate package name
cpio -idmv -D out < test.swu
# Contents will be extracted to 'out'-directory. Decrypt if necessary
```

## Examples


### Example 1: Copy single file

[Docs](https://sbabic.github.io/swupdate/sw-description.html#files)

```bash
# Generate swu package
# swugenerator -a <artifactory (location with payload)> -s <swu descripton file> -o <output filename> create
swugenerator -a files -s description/swudesc_single_file -o test.swu create
```

### Example 2: Run script

[Docs](https://sbabic.github.io/swupdate/sw-description.html#scripts)

```bash
# Generate example
swugenerator -a files -s description/swudesc_shellscript -o test.swu create

# Run swupdate (To see stdout from script, use -l 4 to enable trace level logging)
./swupdate -w "--document-root examples/www/v2" -l 4
```

### Example 3: Load a Docker container

[Docs](https://sbabic.github.io/swupdate/handlers.html#docker-handlers)

```bash
# Run container with docker socket mounted
docker run -it --rm -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock swupdate

# Save image to file, and remove from docker to test
docker pull busybox
docker save busybox > files/busybox.tar
docker image rm busybox

# Create swupdate package
swugenerator -a files -s description/swudesc_docker -o test.swu create

# Image should appear in docker again after running swupdate
watch docker images -f reference=busybox
```

### Example 4: Signed image

[Docs](https://sbabic.github.io/swupdate/signed_images.html)

```bash
# Generate file with password
echo mypassword > password

# Generate private key
openssl genrsa -aes256 -passout file:password -out priv.pem
# Generate public key
openssl rsa -in priv.pem -out public.pem -outform PEM -pubout -passin file:password


# 'sha256' attribute must be added to all images in sw description
# manually, e.g.;
openssl dgst -sha256 files/busybox.tar
# or
sha256sum files/busybox

# OR let swugenerator handle signing for you
# Generate signed swu package
swugenerator -a files -s description/swudesc_docker -k RSA,priv.pem,password -o test.swu create


################################################
# On target host
################################################

# Copy public key to swupdate host

# Run swupdate with signed images enabled
# OpenSSL, 'Allow to add sha256', and 'Enable verification of signed images' must be enabled in build options
# Run swupdate with -k flag to pass public key
./swupdate -k public.pem -w "--document-root examples/www/v2"
```

### Example 5: Encrypted image (aes-256-cbc)

This example uses symmetrical encryption using the AES block cipher in CBC mode

[Docs](https://sbabic.github.io/swupdate/encrypted_images.html)

```bash
# Create 32-byte key
key=`openssl rand -hex 32`
# Create 16-byte initialisation vector (iv)
ivt=`openssl rand -hex 16`

printf $key > enc_key
printf $ivt > enc_ivt
# Key & ivt in format for target (where swupdate is running):
printf "$key $ivt" > enc_key_target
# Key and ivt in format for swugenerator:
printf "key=$key\niv=$ivt" > enc_key_ivt

# Manually encrypt an image
openssl enc -aes-256-cbc -in <INFILE> -out <OUTFILE> -K <KEY> -iv <IV>
# Add outfile, iv, and 'encrypted = true' attribute to swudescription

# OR
# Use swugenerator (-t to also encrypt swudescription)
# Artifacts with 'encrypted = true' attribute will be encrypted, iv's will be automatically created
swugenerator -a files -s description/swudesc_single_file_encrypted -K enc_key_ivt -o test.swu create


################################################
# On target host
################################################

# Copy enc_key_target (aes key + iv separated by space) to swupdate host

# OpenSSL, 'Images can be encrypted', must be enabled in build options
# Optionally 'Even sw-description is encrypted', can be enabled
# Run swupdate with -K flag to pass the key
./swupdate_unstripped -K enc_key_target -w "--document-root examples/www/v2"
```

### Example 6: Signed, encrypted, and compressed Docker image

```bash
# Run container with docker socket mounted
docker run -it --rm -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock swupdate

# Save image to file, and remove from docker to test
docker pull busybox
docker save busybox > files/busybox.tar
docker image rm busybox

# In swudescription set properties 'encrypted = true;' and 'compressed = "zlib";'

# For docker_imageload handler, add the following attribute:
# properties: {decompressed-size = "<decompressed size>"; };
# NOTE: If image is only encrypted and not compressed, use 'decrypted-size' instead

# A variable can be used instead of hardcoding the size in swudescription
# Define a variable like this in swudescription: @@variable_name@@
# Calulate uncompressed file size in bytes:
image_size=`stat --format="%s" files/busybox.tar`
# Generate a config file for swugenerator:
cat > swugen.conf <<EOL
variables: {
    DECOMPRESSED_SIZE="$image_size";
};
EOL

# Pass config to swugenerator with -c flag, and it will replace variables
# in swudescription with the values
swugenerator -a files -s description/swudesc_docker_encrypted -c swugen.conf -K enc_key_ivt -k RSA,priv.pem,password -o test.swu create

################################################
# On target host
################################################

# Copy public key and aes key to swupdate host

# Run swupdate with -K and -k flags
./swupdate -K enc_key_target -k public.pem -w "--document-root examples/www/v2"
```

### Documentation and helpful links

[swupdate GitHub](https://github.com/sbabic/swupdate/)

[swugenerator GitHub](https://github.com/sbabic/swugenerator/)

[swupdate documentation](https://sbabic.github.io/swupdate/index.html)

[YouTube playlist](https://www.youtube.com/playlist?list=PLK9xZawczYSDCG8whHT48N9v3X9BfcbOL)

[swupdate website](https://swupdate.org/)