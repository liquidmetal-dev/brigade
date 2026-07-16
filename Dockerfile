# Multi-stage build: assemble a prod OTP release, then ship it on a slim runtime.
# Base tags track mise.toml (Elixir 1.18.4 / Erlang 27.3.4.14) — keep in sync.
# The -slim variant of the same debian release (bookworm) is used at runtime so
# glibc / OpenSSL / libstdc++ match the ERTS the release was built against.
ARG ELIXIR_IMAGE=hexpm/elixir:1.18.4-erlang-27.3.4.14-debian-bookworm-20260713-slim
ARG RUNTIME_IMAGE=debian:bookworm-slim

# ---- build stage ----------------------------------------------------------
FROM ${ELIXIR_IMAGE} AS build

# Version normally comes from the git tag (release.yml passes --build-arg);
# falls back to the mix.exs literal when unset.
ARG BRIGADE_VERSION
ENV BRIGADE_VERSION=${BRIGADE_VERSION}
ENV MIX_ENV=prod

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential git \
  && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

# Deps first for layer caching.
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# App sources + config. config/ is needed for both compile-time and
# runtime.exs (copied into the release automatically).
COPY config config
COPY lib lib

RUN mix compile
RUN mix release

# ---- runtime stage --------------------------------------------------------
FROM ${RUNTIME_IMAGE} AS runtime

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Run as a non-root user.
RUN useradd --create-home --uid 1000 brigade
WORKDIR /app

COPY --from=build --chown=brigade:brigade /app/_build/prod/rel/brigade ./
USER brigade

# gRPC (9091), metrics (9568), status/healthz (9600). See config/config.exs.
EXPOSE 9091 9568 9600

ENTRYPOINT ["/app/bin/brigade"]
CMD ["start"]
