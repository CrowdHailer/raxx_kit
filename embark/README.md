# Embark

**Begin a new Tokumei application**

```
docker run -v $(pwd):/tmp tokumei/embark my_app
```

## Contributing

Steps to push a new image to docker hub.

*Make sure date in dockerfile is updated.*

```
mix archive.build -o embark.ez
docker build . -t tokumei/embark
docker tag tokumei/embark tokumei/embark[:<tag>]
```
