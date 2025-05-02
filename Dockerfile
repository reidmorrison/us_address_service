#
# Stage 1: Build and test.
#
FROM elixir:1.17 as build
WORKDIR /opt/build
ARG MD_LICENSE=""
ENV MD_LICENSE=${MD_LICENSE} \
    MIX_ENV=prod \
    APP_NAME="us_address_service"

# Copy source code into Docker instance for compilation.
COPY ./us_address_service us_address_service
COPY ./us_address us_address

# Copy Melissa Data Data Files
COPY ./dqs/data /opt/data
COPY ./dqs/libmdAddr.so /usr/lib
COPY ./dqs/*.h us_address/src/

RUN cd us_address \
    && rm -Rf _build \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get \
    && make \
    && mix test

RUN cd us_address_service \
    && rm -Rf _build \
    && mix deps.get \
    && MIX_ENV=test mix test \
    && echo "===== Create Release =====" \
    && MIX_ENV=prod mix release

#
# Stage 2: Build final image copying released binaries from build stage.
#
FROM  debian:buster

ARG MD_LICENSE=""
ARG BUGSNAG_API_KEY=""
ENV MD_LICENSE=${MD_LICENSE} \
    BUGSNAG_API_KEY=${BUGSNAG_API_KEY} \
    LANG=C.UTF-8 \
    HOME=/opt/app
WORKDIR $HOME

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends libssl1.1

COPY --from=build /opt/build/us_address_service/_build/prod/rel/us_address_service ./
COPY --from=build /opt/data /opt/data
COPY --from=build /usr/lib/libmdAddr.so /usr/lib

RUN chown -R nobody: $HOME
USER nobody

CMD ["bin/us_address_service", "start"]
