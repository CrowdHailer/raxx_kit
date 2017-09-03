FROM elixir:1.5.1

ARG CONTAINER_USER='elixir'

RUN useradd -m -u 1000 -s /usr/bin/bash "${CONTAINER_USER}"

USER "${CONTAINER_USER}"

WORKDIR /home/"${CONTAINER_USER}"

COPY . /home/"${CONTAINER_USER}"

RUN mix compile && mix archive.build && mix archive.install --force

WORKDIR /tmp

ENTRYPOINT ["mix", "embark"]
