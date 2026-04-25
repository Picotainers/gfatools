# gfatools
Source-built static `gfatools` container.

## how to use
```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/gfatools:latest gfatools --help
```

## example
```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/gfatools:latest gfatools stat /data/graph.gfa
```

## Quick Usage

```bash
# Pull the image
docker pull docker.io/picotainers/gfatools:latest

# Run the tool
docker run --rm docker.io/picotainers/gfatools:latest gfatools --help
```
