nginx:
  worker_processes: 2
  client_body_buffer_size: 5m
  proxy_connect_timeout: 600
  proxy_send_timeout: 600
  proxy_read_timeout: 600
  send_timeout: 600
