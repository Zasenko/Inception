FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy the script that generates the SSL certs
COPY ./tools/script.sh /root/script.sh

# Make the script executable
RUN chmod +x /root/script.sh

# Run the script when the container starts
CMD ["/root/script.sh"]

