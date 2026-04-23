# gfatools
Source-built static `gfatools` container for working with assembly graphs in GFA format.

## Quick Usage
```bash
docker run --rm docker.io/picotainers/gfatools --help
```

## Usage
Show help:
```bash
docker run --rm docker.io/picotainers/gfatools --help
```

Run graph statistics:
```bash
docker run --rm -v "$(pwd):/data" docker.io/picotainers/gfatools stat /data/graph.gfa
```

## Building
```bash
docker build -t picotainers/gfatools .
```