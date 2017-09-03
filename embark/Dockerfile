FROM elixir:1.5.1

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2017-09-02

COPY . /installer/
WORKDIR /installer
RUN mix compile && mix archive.build && mix archive.install --force

WORKDIR /tmp

ENTRYPOINT ["mix", "embark"]
