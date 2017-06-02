# Tokumei

**Tiny but MIGHTY Elixir webframework**

## Dive in

<!-- *Know all about mix and umbrella projects? [Jump onwards to add tokumei in an exitsting project]()* -->

*N.B. Generator outdated setups up 0.3.0 project*
```
mix archive.install https://github.com/crowdhailer/tokumei/raw/master/tokumei_new.ez
mix tokumei.new my_app
cd my_app
iex -S mix
```

visit [localhost:8080](localhost:8080])

## Usage


```
mix archive.build
docker build . -t installer
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
