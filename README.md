# gfatools
Source-built static `gfatools` container.

## how to use
```bash
docker run --rm -v "$(pwd):/data" picotainers/gfatools:latest --help
```

## example
```bash
docker run --rm -v "$(pwd):/data" picotainers/gfatools:latest stat /data/graph.gfa
```
