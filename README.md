# examples-provider-sops

This is a collection of examples demonstrating how to use the extended functionality implemented [here](https://github.com/binlab/terraform-provider-sops/pull/1) with `env = {}` as a configuration parameter. The key objectives and reasons for this implementation are:

---

- Each resource within one **SOPS** provider can have a different encrypted file with distinct encryption method(s) and separate environment-variable sets. In the example below, we use different **AGE** `recipients` for different files. In practice, you could have any number of methods (e.g., **AGE**, **GPG**, etc.).

- We provide the `env = {}` configuration parameter at **resource level**, **not** at provider level. This is important because setting it at provider level would mean a single command or secret/key for _all_ **SOPS** files (or at least just a few different SOPS secrets engines where the ENV variables do not overlap). If you set it at provider level, it becomes very difficult to support dynamic configuration (currently only [supported](https://github.com/opentofu/opentofu/blob/v1.9/CHANGELOG.md#190) in OpenTofu but [not in Terraform](https://support.hashicorp.com/hc/en-us/articles/6304194229267-Using-count-or-for-each-in-Provider-Configuration)) and impossible to use with Terraform modules (see [this](https://developer.hashicorp.com/terraform/language/modules/develop/providers) and [this](https://developer.hashicorp.com/terraform/language/modules/develop/providers#legacy-shared-modules-with-provider-configurations)).

- We implement a Go mutex [here](https://github.com/binlab/terraform-provider-sops/blob/9de12bcdf91299c427bc43525c2d35f9d3b3ca9f/sops/read_data.go#L31) to prevent race conditions when the same `ENV` name is used with different values. The same outcome could be achieved (see example [ordered-resources](./ordered-resources/)) but the `depends_on` meta-argument does not support dynamic configuration. Another alternative is to use `terraform apply -parallelism=n`, but in that case you lose speed.

- When using [ephemeral resources](https://developer.hashicorp.com/terraform/language/block/ephemeral) with the `external` or `sops` providers, it guarantees that secrets provided through `env = {}` will **not** be exposed in the unencrypted Terraform state file.

- If you don’t need any parameters in the `provider {}` block you can omit it in the Terraform configuration (all examples below reflect this).

---

### Examples

1. [ordered-resources](./ordered-resources/)

   > In this example, resources are ordered by Terraform’s internal mechanism `depends_on`. This guarantees that different ENVs do not overlap with each other. However, this was an early development example prior to implementing the Go mutex; it is no longer necessary.

2. [sops-age-key-cmd](./sops-age-key-cmd/)

   > This example demonstrates the most straightforward way to use the feature `env = {}` in **SOPS** resources by providing an exec command directly to `SOPS_AGE_KEY_CMD`. This only works for **SOPS** secrets engines that provide `*_CMD` environment variables to obtain the secret key.

3. [external-multi-exec](./external-multi-exec/)

   > This example shows a universal method to obtain a secret key via a Terraform `external` resource. This approach enables usage of **SOPS** secrets engines that cannot provide `*_CMD` environment variables. The only requirement is that the **SOPS** provider must accept an ENV for passing the secret key—here we use `SOPS_AGE_KEY` for the **AGE**-based SOPS secret engine.

4. [external-one-exec](./external-one-exec/)

   > This example has the same functionality as [external-multi-exec](./external-multi-exec/) except: some smart logic avoids extra exec to an external secrets store if the private key is the same for multiple files. In that case we issue only one request/exec to the external secrets store. We check **AGE** `recipients` in this scenario.

---

### Notes

- Tested with **OpenTofu** `v1.10.6` (expected to work with **Terraform** as well)

- In all examples we use a custom script `keepassxc-kph` to retrieve private secret keys from **KeePassXC** by browser-integration protocol (see more at [KeePassXC browser integration docs](https://keepassxc.org/docs/KeePassXC_GettingStarted#_browser_integration) and [protocol specification](https://github.com/keepassxreboot/keepassxc-browser/blob/develop/keepassxc-protocol.md)). You can replace this with the CLI of your secrets manager (e.g., **Bitwarden**, **1Password**, etc.).
- In all examples we employ the **AGE**-based **SOPS** secret engine, as a modern open-source solution supporting both `SOPS_AGE_KEY` and `SOPS_AGE_KEY_CMD` environment variables out of the box in **SOPS**.
- Example files encrypted with the following **AGE** keys:

  ```
  # Age Key #0
  age1a64y5xkthnfzknteqhr44cfrsc89vwtqkwjm33dt00hdw5lmkdpq38vlmj
  AGE-SECRET-KEY-10667F4KSEVS6QDUK08HHWR64S6GVMM74MDYJ8AG99V32RGU5VXVQ86ZSJQ
  ```

  ```
  # Age Key #1
  age1ju940d0eeanelukuvv77sjzf9nq0qzwfcmznm8r9sjvej3n6fqfqz2y6xp
  AGE-SECRET-KEY-1Q8SNRMDJQ3SN53L8M8QGYL3KH3R2ECKU0ERTLCML4N42UG3F447S58Z80W
  ```

  You will need to add these to your secrets manager to test the examples here (or generate your own **AGE** keys and your own **SOPS**-encrypted files).

---

### Useful links

- Official **SOPS** documentation: [https://getsops.io/](https://getsops.io/)
- Official **AGE** encryption tool documentation: [https://github.com/age-sops/age](https://github.com/age-sops/age)
- **Rage**: Rust implementation of **Age**: [https://github.com/str4d/rage](https://github.com/str4d/rage)
- Original Terraform provider for **SOPS**: [https://registry.terraform.io/providers/carlpett/sops/latest/docs](https://registry.terraform.io/providers/carlpett/sops/latest/docs)
- Fork of Terraform provider for **SOPS**: [https://registry.terraform.io/providers/binlab/sops/latest/docs](https://registry.terraform.io/providers/binlab/sops/latest/docs)
