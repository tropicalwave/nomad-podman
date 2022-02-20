job "demo-webapp" {
  datacenters = ["dc1"]

  group "demo" {
    scaling {
      enabled = true
      min = 2
      max = 5
      policy {
      }
    }

    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/myapp`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        NGINX_PORT = "${NOMAD_PORT_http}"
        NGINX_HOST = "${NOMAD_IP_http}"
      }

      driver = "podman"

      config {
        image = "docker.io/nginx:stable-alpine"
        ports = ["http"]

        volumes = [
          "local/default.conf.template:/etc/nginx/templates/default.conf.template",
          "local/myapp:/usr/share/nginx/html/myapp",
        ]
      }

      template {
        data = <<EOF
server {
    listen       ${NGINX_PORT};
    server_name  ${NGINX_HOST};


    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
	default_type text/html;
    }


    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
        destination = "local/default.conf.template"
      }

      template {
        data = <<EOF
hello from port {{ env "NOMAD_PORT_http" }}
EOF
        destination = "local/myapp"
      }
    }
  }
}

