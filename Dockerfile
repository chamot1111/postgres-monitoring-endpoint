# Stage 1: Download redbean and run package.sh
FROM alpine:latest as builder

# Install curl
RUN apk add --update curl

ARG DOWNLOAD_FILENAME=redbean-3.0.0.com

# Download redbean.com
RUN curl -o redbean.com https://redbean.dev/${DOWNLOAD_FILENAME}
RUN chmod +x redbean.com

# Add assimilate binary
RUN curl -o /usr/local/bin/assimilate https://cosmo.zip/pub/cosmos/bin/assimilate && \
    chmod +x /usr/local/bin/assimilate

RUN curl -o /usr/local/bin/zip https://cosmo.zip/pub/cosmos/bin/zip && \
    chmod +x /usr/local/bin/zip

RUN assimilate redbean.com

# Copy package.sh into the container
COPY package.sh .
COPY .init.lua health.lua ./
COPY .lua .lua

# Check if .lua/pgmoon/init.lua exists
RUN if [ ! -f .lua/pgmoon/init.lua ]; then echo ".lua/pgmoon/init.lua not found" && exit 1; fi && \
    ls -la .lua

# Make package.sh executable
RUN chmod +x package.sh

# Run package.sh
RUN ./package.sh

RUN ls -la redbean.com
RUN zip -sf redbean.com

# Stage 2: Create the final image
FROM scratch

# Copy redbean.com from the builder stage
COPY --from=builder /redbean.com .

# Set the entrypoint to run redbean.com
ENTRYPOINT ["./redbean.com"]
