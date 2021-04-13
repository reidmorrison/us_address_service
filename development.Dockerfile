# See README.md for details on using this file.
FROM elixir:1.11
WORKDIR /src
ARG MD_LICENSE=""
ENV MD_LICENSE=${MD_LICENSE} \
    ADDRESS_POOL_SIZE=10 \
    ADDRESS_OVERFLOW_SIZE=2 \
    PORT=4000

# Copy Melissa Data Files for better performance
COPY ./dqs/data /opt/data
COPY ./dqs/libmdAddr.so /usr/lib
COPY ./dqs/*.h postal_address/src/

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y apache2-utils

CMD ["bash"]
