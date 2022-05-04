ARG MIX_ENV="prod"

FROM hexpm/elixir:1.12.1-erlang-24.1.5-alpine-3.14.2 as build

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib
COPY config/runtime.exs config/

COPY assets assets

# compile assets
RUN mix assets.deploy

COPY rel rel

RUN mix release

FROM alpine:3.12.1 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

WORKDIR "/home/${USER}/app"

# Creates an unprivileged user to be used exclusively to run the Elixir app
RUN \
  addgroup \
    -g 1000 \
    -S "${USER}" \
    && adduser \
    -s /bin/sh \
    -u 1000 \
    -G "${USER}" \
    -h "/home/${USER}" \
    -D "${USER}" \
    && su "${USER}"

# Everything from this line onwards will run in the context of the unprivileged user.

USER "${USER}"
COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/ahappybot ./

ENTRYPOINT ["bin/ahappybot"]

# Usage:
#  * build: sudo docker image build -t silbermm/ahappybot .
#  * shell: sudo docker container run --rm -it --entrypoint "" silbermm/ahappybot sh
#  * run:   sudo docker container run --rm -it --name ahappybot silbermm/ahappybot
#  * exec:  sudo docker container exec -it ahappybot sh
#  * logs:  sudo docker container logs --follow --tail 100 ahappybot
CMD ["start"]
