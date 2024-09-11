curl -L https://github.com/nats-io/nats-server/releases/download/v2.8.4/nats-server-v2.8.4-linux-amd64.tar.gz -o nats-server.tar.gz
tar -xzf nats-server.tar.gz
cd nats-server-v2.8.4-linux-amd64 && ./nats-server -c ../nats.conf
