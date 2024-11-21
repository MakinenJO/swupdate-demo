Install azure CLI from [here](https://learn.microsoft.com/en-us/cli/azure/)
Install Go from [here](https://go.dev/doc/install)


```bash
# Login to azure
az login
# With multiple tenants use
az login -t <tenant-id>

# Login to registry
az acr login -n <registryname>

# Build regclient
git clone https://github.com/okoko/regclient.git
cd regclient
git switch save-many
make

# To make regctl visible in path
ln -s $PWD/bin/regctl ~/bin/regctl # on MacOS bin folder is in ~/.local/bin/regctl

# List images in registry
regctl repo ls <url>

# List image tags
regctl tag ls alpine

# Save image to file
regctl image save --platform amd64 alpine > alpine.tar

# Load into docker
docker load < alpine.tar
```


## Test GitHub Actions locally with act

[Docs](https://nektosact.com/introduction.html)
[Repo](https://github.com/nektos/act)

```bash
brew install act

gh extension install https://github.com/nektos/gh-act

# [On MacOS you might have to create a symlink so act can find the docker socket](https://github.com/nektos/act/issues/1658)
ln -s ~/.docker/run/docker.sock /var/run/docker.sock

# Run act
cd <your-repo>
act

```