# Embark

**Begin a new Tokumei application**

```
docker run -v $(pwd):/tmp tokumei/embark hello_tokumei

sudo chown -R $USER:$USER hello_tokumei
```

## Contributing

Steps to push a new image to docker hub.

*Make sure date in dockerfile is updated.*

```
docker build . -t tokumei/embark
docker tag tokumei/embark tokumei/embark[:<tag>]
docker push tokumei/embark
```
