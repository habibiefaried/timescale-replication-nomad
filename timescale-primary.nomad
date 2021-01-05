job "timescale-primary" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.platform.aws.placement.availability-zone}"
    value     = "ap-southeast-1a"
  }
  
  group "demo" {
    count = 1
    volume "timescale-primary" {
      type      = "csi"
      read_only = false
      source    = "timescale-primary"
    }

    network {
      port "timescale_primary" { 
        to = 5432
        static = 5432
      }
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "timescale-primary"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      env {
        POSTGRES_USER = "postgres"
        POSTGRES_PASSWORD = "postgres21"
        REPLICA_POSTGRES_USER = "repuser"
        REPLICA_POSTGRES_PASSWORD = "repuser21"
        PGDATA = "/var/lib/postgresql/data/pgdata"
        REPLICATION_SUBNET = "0.0.0.0/0"
        REPLICA_NAME = "timescalereplica"
        SYNCHRONOUS_COMMIT = "on"
      }

      config {
        image = "habibiefaried/timescale-replication"
        ports = ["timescale_primary"]
      }

      resources {
        cpu    = 256
        memory = 1024
      }
    }

    service {
      name = "timescale-primary"
      port = "timescale_primary"

      check {
        port        = "timescale_primary"
        type        = "tcp"
        interval    = "10s"
        timeout     = "9s"
      }
    }
  }
}