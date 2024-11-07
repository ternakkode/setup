curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
sudo tailscale set --advertise-exit-node
sudo tailscale up
