global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http_front
    bind *:80
    default_backend servers

backend servers
    balance roundrobin
    option httpchk
    http-check send meth GET uri /health
    http-check expect status 200
    server web0 ${ipserver0}:80 maxconn 32 check
    server web1 ${ipserver1}:80 maxconn 32 check

listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 10s
    stats auth admin:admin
