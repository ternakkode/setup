sudo apt update
sudo apt install wireguard

sudo cp client.conf /etc/wireguard/

sudo wg-quick up client
sudo wg
sudo wg-quick down client