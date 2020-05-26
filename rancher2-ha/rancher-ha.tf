# Set up resource definitions and namespaces
resource "null_resource" "cert-manager-crds" {
  provisioner "local-exec" {
    command = <<EOF
kubectl apply  --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v${local.certmanager_version}/cert-manager.crds.yaml
kubectl create namespace cert-manager
kubectl create namespace cattle-system
helm repo add jetstack https://charts.jetstack.io
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
EOF
    environment = {
      KUBECONFIG = local_file.kube_cluster_yaml.filename
    }
  }
}

# Install cert-manager
resource "helm_release" "cert_manager" {
  depends_on = [null_resource.cert-manager-crds]
  version    = "v${local.certmanager_version}"
  name       = "cert-manager"
  chart      = local.certmanager_chart
  namespace  = "cert-manager"

  # Bogus set to link together resources for proper tear down
  set {
    name  = "tf_link"
    value = rke_cluster.rancher_node.api_server_url
  }
}

# Install Rancher via Helm
resource "helm_release" "rancher" {
  name      = "rancher"
  chart     = local.rancher_chart
  version   = "v${local.rancher_version}"
  namespace = "cattle-system"

  set {
    name  = "hostname"
    value = local.domain
  }

  set {
    name  = "ingress.tls.source"
    value = "letsEncrypt"
  }

  set {
    name  = "letsEncrypt.email"
    value = local.le_email
  }

  set {
    name  = "letsEncrypt.environment"
    value = "production" # valid options are 'staging' or 'production'
  }

  # Bogus set to link togeather resources for proper tear down
  set {
    name  = "tf_link"
    value = helm_release.cert_manager.name
  }
}

resource "null_resource" "wait_for_rancher" {
  provisioner "local-exec" {
    command = <<EOF
while [ "$${subject}" != "*  subject: CN=$${RANCHER_HOSTNAME}" ]; do
  subject=$(curl -vk -m 2 "https://$${RANCHER_HOSTNAME}/ping" 2>&1 | grep "subject:")
  echo "Cert Subject Response: $${subject}"
  if [ "$${subject}" != "*  subject: CN=$${RANCHER_HOSTNAME}" ]; then
    sleep 10
  fi
done
while [ "$${resp}" != "pong" ]; do
  resp=$(curl -sSk -m 2 "https://$${RANCHER_HOSTNAME}/ping")
  echo "Rancher Response: $${resp}"
  if [ "$${resp}" != "pong" ]; then
    sleep 10
  fi
done
EOF

    environment = {
      RANCHER_HOSTNAME = "${local.domain}"
      TF_LINK          = helm_release.rancher.name
    }
  }
}

# Update admin password and turn telemetry off
resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  depends_on = [null_resource.wait_for_rancher]

  current_password = local.rancher_current_password
  password         = local.rancher_password

  telemetry = false
}
