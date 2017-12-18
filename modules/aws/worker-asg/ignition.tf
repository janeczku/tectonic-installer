data "ignition_config" "main" {
  files = [
    "${var.ign_installer_kubelet_env_id}",
    "${var.ign_installer_runtime_mappings_id}",
    "${var.ign_max_user_watches_id}",
    "${var.ign_s3_puller_id}",
    "${var.ign_ca_cert_id_list}",
    "${var.dns_server_ip != "" ? join("", data.ignition_file.node_resolv.*.id) : ""}",
  ]

  systemd = [
    "${var.ign_docker_dropin_id}",
    "${var.ign_k8s_node_bootstrap_service_id}",
    "${var.ign_kubelet_service_id}",
    "${var.ign_locksmithd_service_id}",
    "${var.ign_update_ca_certificates_dropin_id}",
  ]
}

// DNS Server resolution
data "template_file" "node_resolv" {
  count    = "${var.dns_server_ip != "" ? 1 : 0}"
  template = "search ${data.aws_region.current.name}.compute.internal\nnameserver ${var.dns_server_ip}"
}

data "ignition_file" "node_resolv" {
  count      = "${var.dns_server_ip != "" ? 1 : 0}"
  path       = "/etc/resolv.conf"
  mode       = 0644
  filesystem = "root"

  content {
    content = "${data.template_file.node_resolv.rendered}"
  }
}
