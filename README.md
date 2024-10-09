# SWUpdate Demo

## SWUpdate containerized setup

### Build and run container
```bash
docker build -t swupdate .
docker run -it --rm -p 8080:8080 swupdate
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


### Example 1: Copy single file

```bash
# Generate swu package
# swugenerator -a <artifactory (location with payload)> -s <swu descripton file> -o <output filename> create
swugenerator -a files -s description/swudesc_single_file -o test.swu create
```

### Example 2: Run script
```bash

```

### Example 3: Start and stop a Docker container
```bash

```

### Documentation and helpful links

[seupdate GitHub](https://github.com/sbabic/swupdate/)

[swugenerator GitHub](https://github.com/sbabic/swugenerator/)

[swupdate documentation](https://sbabic.github.io/swupdate/index.html)

[YouTube playlist](https://www.youtube.com/playlist?list=PLK9xZawczYSDCG8whHT48N9v3X9BfcbOL)

[swupdate website](https://swupdate.org/)