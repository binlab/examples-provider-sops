locals {
  sops = {
    global = {
      data  = file("../secrets0.sops.yaml")
      stage = "one"
    }
    system = {
      data  = file("../secrets1.sops.yaml")
      stage = "two"
    }
    users = {
      data  = file("../secrets2.sops.yaml")
      stage = "three"
    }
  }
}

data "external" "one" {
  for_each = {
    for k, v in local.sops : k => v.data if v.stage == "one"
  }

  program = split(" ",
    format(var.age_command,
      yamldecode(each.value)["sops"]["age"][0]["recipient"]
    )
  )
}

data "external" "two" {
  for_each = {
    for k, v in local.sops : k => v.data if v.stage == "two"
  }

  program = split(" ",
    format(var.age_command,
      yamldecode(each.value)["sops"]["age"][0]["recipient"]
    )
  )

  depends_on = [
    data.external.one
  ]
}

data "external" "three" {
  for_each = {
    for k, v in local.sops : k => v.data if v.stage == "three"
  }

  program = split(" ",
    format(var.age_command,
      yamldecode(each.value)["sops"]["age"][0]["recipient"]
    )
  )

  depends_on = [
    data.external.two
  ]
}

data "sops_external" "one" {
  for_each = {
    for k, v in local.sops : k => v.data if v.stage == "one"
  }

  source     = each.value
  input_type = "yaml"
  env = {
    SOPS_AGE_KEY = data.external.one[each.key].result.password
  }
}

data "sops_external" "two" {
  for_each = {
    for k, v in local.sops : k => v.data if v.stage == "two"
  }

  source     = each.value
  input_type = "yaml"
  env = {
    SOPS_AGE_KEY = data.external.two[each.key].result.password
  }

  depends_on = [
    data.external.one
  ]
}

data "sops_external" "three" {
  for_each = {
    for k, v in local.sops : k => v.data if v.stage == "three"
  }

  source     = each.value
  input_type = "yaml"
  env = {
    SOPS_AGE_KEY = data.external.three[each.key].result.password
  }

  depends_on = [
    data.external.two
  ]
}
