```bash
docker build -t swupdate .
docker run -it --rm -v .config:/swupdate/.config

cd swupdate
./ci/setup.sh
./ci/install-src-deps.sh

```

```bash
make menuconfig
make

./swupate
```

[swupdate documentation](https://sbabic.github.io/swupdate/index.html)
[YouTube playlist](https://www.youtube.com/playlist?list=PLK9xZawczYSDCG8whHT48N9v3X9BfcbOL)
[swupdate website](https://swupdate.org/)