# Wait for Docker to be installed on all nodes
resource "null_resource" "wait_for_docker" {
  count = local.instance_count

  triggers = {
    instance_ids = join(",", concat(aws_instance.rancher_node.*.id))
  }

  provisioner "local-exec" {
    command = "sleep 120" // Cannot access the nodes under secuure network anymore because they are in the private network.
  }
}

### RKE Cluster

resource "aws_s3_bucket" "etcd_backups" {
  bucket        = "${local.domain}-rke-etcd-backup"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_iam_user" "etcd_backup_user" {
  name          = "${local.name}-etcd-backup"
  force_destroy = true
}

resource "aws_iam_access_key" "etcd_backup_user" {
  user = aws_iam_user.etcd_backup_user.name
}

resource "aws_iam_user_policy" "etcd_backup_user" {
  name = "${aws_iam_user.etcd_backup_user.name}-policy"
  user = aws_iam_user.etcd_backup_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "etcdBackupBucket",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.etcd_backups.arn}",
                "${aws_s3_bucket.etcd_backups.arn}/*"
            ]
        }
    ]
}
EOF

}

resource "rke_cluster" "rancher_node" {
  depends_on = [null_resource.wait_for_docker]

  dynamic nodes {
    for_each = aws_instance.rancher_node[*]
    content {
      address          = nodes.value.public_ip
      internal_address = nodes.value.private_ip
      user             = local.instance_user
      role             = ["controlplane", "etcd", "worker"]
      ssh_key          = tls_private_key.ssh.private_key_pem
    }
  }

  cluster_name = "rancher"
  addons       = file("${path.module}/../config-files/addons.yaml")

  authentication {
    strategy = "x509"

    sans = [
      local.api_server_hostname
    ]
  }

  services {
    etcd {
      # for etcd snapshots
      backup_config {
        interval_hours = 12
        retention      = 6
        # s3 specific parameters
        s3_backup_config {
          access_key  = aws_iam_access_key.etcd_backup_user.id
          secret_key  = aws_iam_access_key.etcd_backup_user.secret
          bucket_name = aws_s3_bucket.etcd_backups.id
          region      = local.rke_backup_region
          #        folder      = local.name
          endpoint = local.rke_backup_endpoint
        }
      }
    }
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/outputs/kube_config_cluster.yml"
  content = templatefile("${path.module}/../config-files/kube_config_cluster.yml", {
    api_server_url     = local.api_server_url
    rancher_cluster_ca = base64encode(rke_cluster.rancher_node.ca_crt)
    rancher_user_cert  = base64encode(rke_cluster.rancher_node.client_cert)
    rancher_user_key   = base64encode(rke_cluster.rancher_node.client_key)
  })
}


# kubectl --kubeconfig ./outputs/kube_config_cluster.yml get version
