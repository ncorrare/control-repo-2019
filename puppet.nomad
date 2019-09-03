job "puppet" {
  region = "uk"
  type = "service"
  datacenters = ["dc1"]
  update {
    stagger      = "30s"
    max_parallel = 2
  }
  group "api" {
    count = 1
    task "web" {
      env {
        CONSUL_HTTP_ADDR = "http://${attr.unique.network.ip-address}:8500"
        VAULT_ADDR = "https://vault.stn.corrarello.net"
        VAULT_SKIP_VERIFY = "true"
        NOMAD_ADDR = "http://${attr.unique.network.ip-address}:8500"
      }
      vault {
        policies = ["puppet-master"]

        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<EOF
        {{ with secret "pki-intermediate/crl/pem"}}
        {{ .Data }}{{ end }}
        EOF
        destination   = "/etc/puppet/ssl/crl.pem"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<EOF
        {{ with secret "pki-intermediate/issue/puppet-server" "common_name=puppet.stn.corrarello.net"}}
        {{ .Data.ca_chain }}{{ end }}
        EOF
        destination   = "/etc/puppet/ssl/ca.pem"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
       template {
        data = <<EOF
        {{ with secret "pki-intermediate/issue/puppet-server" "common_name=puppet.stn.corrarello.net"}}
        {{ .Data.certificate }}{{ end }}
        EOF
        destination   = "/etc/puppet/ssl/server-cert.pem"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<EOF
        {{ with secret "pki-intermediate/issue/puppet-server" "common_name=puppet.stn.corrarello.net"}}
        {{ .Data.private_key }}{{ end }}
        EOF
        destination   = "/etc/puppet/ssl/server-key.pem"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
     driver = "docker"
      config {
        image = "ncorrare/puppet-master:latest"
        command = "puppet"
        args = ["master"]
        port_map {
          http = 8140
        }
      }
      service {

        port = "http"

        check {
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "5s"
        }
      }
      resources {
        cpu = 500 # Mhz
        memory = 400 # MB
        network {
          mbits = 50
          port "http" {}
        }
      }
    }
  }
}

