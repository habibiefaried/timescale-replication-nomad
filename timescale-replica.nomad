job "timescale-replica" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.platform.aws.placement.availability-zone}"
    value     = "ap-southeast-1c"
  }
  
  group "demo" {
    count = 1
    volume "timescale-replica" {
      type      = "csi"
      read_only = false
      source    = "timescale-replica"
    }

    network {
      port "timescale_replica" { 
        to = 5432
        static = 5432
      }
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "timescale-replica"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      env {
        POSTGRES_USER = "repuser"
        POSTGRES_PASSWORD = "repuser21"
        PGDATA = "/var/lib/postgresql/data/pgdata"
        REPLICA_NAME = "timescale-replica"
        REPLICATE_FROM = "timescale-primary.service.consul"
      }

      config {
        image = "habibiefaried/timescale-replication"
        ports = ["timescale_replica"]
      }

      resources {
        cpu    = 256
        memory = 1024
      }
    }

    service {
      name = "timescale-replica"
      port = "timescale_replica"

      check {
        port        = "timescale_replica"
        type        = "tcp"
        interval    = "10s"
        timeout     = "9s"
      }
    }
  }
}