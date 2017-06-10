# Tokumei

**Tiny but MIGHTY Elixir webframework**

## Usage

```

docker run -v $(pwd):/tmp installer mix tokumei.new my_app
```
TODO need to `sudo chown $USER:$USER <project>`
be nice to fix this although I think it is linux only.

```
cd my_app
docker-compose up --build -d
```
There is code reloading but for ex files only at the moment

```
docker ps
docker exec -it <container-d> iex --sname debug --cookie secret
iex>
Node.connect(:"web@172.19.0.4")
```

Containers can be named so don't need to lookup id. after that they can only scale to one instance
