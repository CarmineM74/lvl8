# CarmineGql

## Distribution setup

We're also going to start adding nodes, and need to scale our server.
For this we can use LibCluster, so add it in, and set it up so we can have 2 nodes in development (`node_a@localhost` and `node_b@localhost`)

### Notes
- Tests must be written for the GQL part
- Should we also write tests for the auth tokens cache?
