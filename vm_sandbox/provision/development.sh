#! /bin/bash

# Git is installed so that mix can use github.com as a source of dependencies
apt-get install -y git

# Install docker onto development machine
wget -qO- https://get.docker.com/ | sh
usermod -aG docker vagrant
apt-get -y install python-pip
pip install docker-compose

# Install the Elixir and Erlang languages as required.
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
apt-get update
apt-get install -y erlang
apt-get install esl-erlang
apt-get install -y elixir
