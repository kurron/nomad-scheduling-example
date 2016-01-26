# listen on all NICs
bind_addr = "0.0.0.0"

advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  rpc = "10.0.2.15:4647"
}

client {
    # this trick seems to force Nomad to tell Docker to use 10.0.2.15 instead of 127.0.0.1
    network_interface = "eth0"
}
