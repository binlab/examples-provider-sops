locals {
  sops = {
    system = file("../secrets1.sops.yaml")
    users  = file("../secrets2.sops.yaml")
  }
}

data "external" "age" {
  for_each = { for k, v in local.sops :
    yamldecode(v)["sops"]["age"][0]["recipient"] => v...
    if can(yamldecode(v)["sops"]["age"])
  }

  program = split(" ",
    format(var.age_command, each.key)
  )
}

data "sops_external" "age" {
  for_each = { for k, v in local.sops :
    k => {
      data = v
      age  = yamldecode(v)["sops"]["age"][0]["recipient"]
    }
    if can(yamldecode(v)["sops"]["age"])
  }

  source     = each.value.data
  input_type = "yaml"
  env = {
    SOPS_AGE_KEY = data.external.age[each.value.age].result.password
  }
}
