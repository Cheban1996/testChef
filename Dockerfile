FROM rust:1.67-bullseye AS chef
RUN cargo install cargo-chef  
WORKDIR /home/build

FROM chef AS planner
COPY Cargo.lock Cargo.toml ./
COPY server/ ./server
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY Cargo.lock Cargo.toml ./
COPY server/ ./server
COPY --from=planner /home/build/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
RUN cargo build --release

FROM debian:bullseye AS runtime
RUN apt-get update && apt-get install -y
COPY --from=builder /home/build/target/release/server /usr/local/bin/server 
EXPOSE 8080
CMD ["server"]

