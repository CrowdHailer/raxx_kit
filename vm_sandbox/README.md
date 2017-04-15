# Virtual Machine Sandbox

This setup requires [Vagrant](https://www.vagrantup.com/) to be setup.

There are two environments setup:

- development, has Elixir/erlang installed.
- production, clean ubuntu box, three instances started

## Starting Vagrant

Start all vm's

```
vagrant up
```

Access the development environment

```
vagrant ssh development
cd /vagrant
```

## Building a release

```
# vagrant@development

cd /<project-dir>
mix deps.get
MIX_ENV=prod mix release

scp _build/prod/rel/<project-name>/releases/0.1.0/<project-name>.tar.gz vagrant@<production1-ip>:.
```

*NOTE: Don't forget the final `.` which is the path on the target machine to sent the file too.*
*NOTE: Will ask for target machine password, default password is `vagrant`.*
*NOTE: ip's are dynamic, to find appropriate use `eth1` value returned by `ifconfig`.*

## Starting a release

```
vagrant@production1
tar -xf <project-name>.tar.gz
./bin/<project-name> start
```

visit [<production1-ip>](http://172.28.128.4:8080)
