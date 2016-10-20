# Baobab

**An example Cowboy application that might grow to be a routing tree example**

## Installation

  1. Add baobab to your list of dependencies in mix.exs:

        def deps do
          [{:baobab, "~> 0.1.0"}]
        end

  2. Ensure baobab is started before your application:

        def application do
          [applications: [:baobab]]
        end

## Usage

#### Running with Mix

```
# vagrant@development

cd /vagrant
mix deps.get
iex -S mix
```

Visit [localhost:8080](localhost:8080)

#### Manually deploying a distribution

```
# vagrant@development

cd /vagrant
mix deps.get
mix release

scp rel/baobab/releases/0.0.1/baobab.tar.gz vagrant@<dmz ip address>:.
# Find ip following instructions below or setup static ip
# On Digital ocean user is root, add ssh key or expect password in an email.
```

```
# vagrant@dmz

ifconfig
# get private ip_address, use eth1

tar -xf baobab.tar.gz
/bin/baobab start
```

visit http://172.28.128.4:8080/3434 # substitute dmz ip.

Home page doesn't work some issue with compiling eex.

## Roadmap

A long list of things that I need to do to make cloud native applications easier.

- [x] Setup vagrant for this project.
- [x] Build releases with [distillery](https://github.com/bitwalker/distillery)
- [x] Create a production with vagrant.
- [x] Organise DO/GCP credentials
- [ ] Work out how to debug in a vm node.
- [ ] Integrate with provisioning resources, looks like kuberneties, look at katacoda.
- [ ] check nomad for example of cloud integration, [which to choose](https://thehftguy.wordpress.com/2016/06/08/choosing-a-cloud-provider-amazon-aws-ec2-vs-google-compute-engine-vs-microsoft-azure-vs-ibm-softlayer-vs-linode-vs-digitalocean-vs-ovh-vs-hertzner/) DO -> GCP -> (IBM machine images)
- [ ] Setup [DMZ](http://www.erlang-factory.com/static/upload/media/144975595943066francescocesarinieflberlin2015.pdf#14) network area, certain releases from umbrella app. [DO floating ips](https://www.digitalocean.com/products/networking/) to load balancers. make each of [DO server setups](https://www.digitalocean.com/community/tutorials/5-common-server-setups-for-your-web-application)
- [ ] Programmable load balancing from DMZ webservers to application server. One example would be a riak core ring or phoenix presence regestration.

- [real world elixir deployment](https://www.youtube.com/watch?v=H686MDn4Lo8)
- [load balancing websockets](http://www.oxagile.com/company/blog/load-balancing-of-websocket-connections/)
- [Elixir deployment tools](https://elixirforum.com/t/elixir-deployment-tools-general-discussion-blog-posts-wiki/827)
- [Elixir and Erlang cluster](http://bitwalker.org/posts/2016-08-04-clustering-in-kubernetes/)


The first step is to get Buildroot running on the platform. The next is to take a look at one of our system images and modify it based on what you learned about with Buildroot.

: Yes, while Nerves could in theory use other Linux image builders, right now Buildroot is the only one we're supporting. Buildroot has generic x86_64 images that probably get close to what you need. Our root filesystems are all read-only squashfs ones. "Cross-compilation" will sound a little strange since you're on x86_64 already, but the C library that we're using will probably be slightly different so it's still needed.
3:48 Also, we do actually supply an x86_64 cross-compiler that targets the MUSL C library that can be used on OSX, PC Linux, and RPi. I added it a while back when someone else asked me about running on a server. I haven't used it, though. You can find it under the v0.7.1 release at https://github.com/nerves-project/toolchains/releases/. 

^Nerves chat

## Mission
look at phoenix mission silde from 2014

- Encourage domain modelling
- Immutable data history
- independent clients. offline first sharded DB,
- MoSQL

## Names
Anvil, (Anonimous/kernal)
Nimbus, cloud native

Suggestions for securing a DO node.

@crowdhailer I would make sure to have a separate (non-root) user running the Elixir application, at least `ufw` installed to close all other ports than 80/22, and set `PermitRootLogin no` in `/etc/ssh/sshd_config`
Those three things are some quick wins with regards to security of a web app

[setting up a server](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04)
## Glossary

Each machine type has a different release (grouping of applications, assembly, cohort)
## Notes
Instructions on setting up Cowboy are reasonably limited.
Some of these resources are helpful.

- [Cowboy elixir example](https://github.com/IdahoEv/cowboy-elixir-example/blob/master/lib/dynamic_page_handler.ex)
- [Elixir rest with cowboy](http://www.jonasrichard.com/2016/02/elixir-rest-with-cowboy.html)

The plug documentation is also lacking.
It seams only to exist to serve Phoenix, however these articles are helpful.

- [Building a web framework from scratch in Elixir](https://codewords.recurse.com/issues/five/building-a-web-framework-from-scratch-in-elixir)
- [Getting started with Plug in Elixir](http://www.brianstorti.com/getting-started-with-plug-elixir/)
