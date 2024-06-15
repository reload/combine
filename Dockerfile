FROM crystallang/crystal:1.11.2-alpine as builder
RUN mkdir /build
WORKDIR /build
# Add build dependencies.
RUN apk add --no-cache sqlite-static yaml-static
# Copying and install dependencies.
COPY shard.yml shard.lock ./
RUN shards install --production
# Copy the rest of the code.
COPY src/ src/
COPY config/ config/
COPY db/ db/
COPY public/ public/
# Build a static binary.
RUN shards build --release --production --static --no-debug combine
RUN rm -rf lib db/*.db
RUN mkdir storage && chown 1000:1000 storage

FROM scratch
# Don't run as root. This is the core user on delta.
USER 1000:1000
# Copy only the app from the build stage.
COPY --from=builder /build /
# Install a CA store.
COPY --from=builder /etc/ssl/cert.pem /etc/ssl/
COPY --from=builder /usr/share/zoneinfo/Europe/Copenhagen /usr/share/zoneinfo/Europe/
VOLUME /storage

EXPOSE 80

ENV AMBER_ENV=production
ENTRYPOINT ["/bin/combine"]
