node.default[:nginx][:worker_connections] = 4096
node.default[:nginx][:worker_rlimit_nofile] = 100000
node.default[:nginx][:gzip_comp_level] = 6
node.default[:nginx][:keepalive_timeout] = 30