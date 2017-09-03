# Embark

**Begin a new Tokumei application**

```
docker run -v $(pwd):/tmp tokumei/embark hello_tokumei
```

## Contributing

Steps to push a new image to docker hub.

```
docker build --force-rm --no-cache --pull . -t tokumei/embark
docker tag tokumei/embark tokumei/embark[:<tag>]
docker push tokumei/embark
```
