locals {
  sops = {
    global = file("../secrets0.sops.yaml")
    system = file("../secrets1.sops.yaml")
    users  = file("../secrets2.sops.yaml")
  }
}

data "sops_external" "this" {
  for_each = local.sops

  source     = each.value
  input_type = "yaml"
  env = {
    SOPS_AGE_KEY_CMD = format(var.age_command,
      yamldecode(each.value)["sops"]["age"][0]["recipient"]
    )
  }
}
