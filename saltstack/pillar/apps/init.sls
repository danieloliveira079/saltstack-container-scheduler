front-end:
  development:
    app: "frontend"
    app_name: "web.domain.local"
    host: "dev.web.domain.local"
    root_folder: "/var/www/web_local"
    image_namespace: "domain"
    container_name: "web_"
    notify_progress: True
    app_env: "Development"
    scheduler:
      service_name: "web"
      service_port: "8080:80"
      image_name: "nginx"
      tag: "latest"
      options:
        create:
          - "--restart-max-attempts 3"
          - "--update-delay 30s"
          - "--update-parallelism 1"
          - "--replicas 2"
        update:
          - "--update-parallelism 1"
    environment:
      VIRTUAL_HOST: "dev.web.domain.local"
      VIRTUAL_PORT: "8080"
      NODE_ENV: "production"
      API_URL: "http://api.domain.local"
