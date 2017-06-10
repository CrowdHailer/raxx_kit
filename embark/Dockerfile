FROM elixir:1.4.4

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2017-06-11

COPY . /installer/
RUN cd /installer && ls && mix archive.build && mix archive.install --force

WORKDIR /tmp

ENTRYPOINT ["mix", "embark"]
