FROM elixir:1.4.4

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2017-06-11

COPY embark-0.1.0.ez /installer/embark-0.1.0.ez
RUN cd /installer && mix archive.install --force embark-0.1.0.ez

WORKDIR /tmp

RUN pwd

# ENTRYPOINT ["mix", "embark"]
