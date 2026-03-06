terraform {
    required_providers {
        konnect = {
            source  = "kong/konnect"
        }
    }
}

# provider "konnect" {
#     # server_url = "https://global.api.konghq.com" # Default
#     # server_url = "https://us.api.konghq.com"
# }

resource "konnect_event_gateway" "quickstart_gateway" {
    name                = var.keg_name
    description         = var.keg_desc
    labels              = var.keg_labels
}

resource "konnect_event_gateway_backend_cluster" "quickstart_backend_cluster" {
    gateway_id          = konnect_event_gateway.quickstart_gateway.id

    name                = var.keg_backend_name
    description         = var.keg_backend_desc
    labels              = var.keg_backend_labels

    bootstrap_servers   = var.keg_backend_bootsrap_servers
    authentication      = var.keg_backend_authentication

    # Insecure Anon Auth for Virtual Clusters is set to false here to ensure
    # that any deployments leveraging this module are secure by default.
    insecure_allow_anonymous_virtual_cluster_auth = false
    
    metadata_update_interval_seconds = var.keg_backend_metadata_refresh_interval

    tls = merge({
        enabled = (
          var.keg_backend_tls_enabled || 
          var.keg_backend_tls_client_identity != null
        ),
        tls_version = var.keg_backend_tls_versions,
        insecure_skip_verify = var.keg_backend_tls_allow_insecure_verify
      },
      var.keg_backend_tls_client_identity != null ? {client_identity: var.keg_backend_tls_client_identity} : {},
      var.keg_backend_tls_ca_bundle != null ? {ca_bundle: var.keg_backend_tls_ca_bundle} : {},
    )
}

resource "konnect_event_gateway_virtual_cluster" "quickstart_virtual_cluster" {
  gateway_id          = konnect_event_gateway.quickstart_gateway.id
  destination = {
    id                = konnect_event_gateway_backend_cluster.quickstart_backend_cluster.id
  }

  name                = var.keg_virt_name
  description         = var.keg_virt_desc
  labels              = var.keg_virt_labels

  authentication      = [var.keg_virt_authentication]
  acl_mode            = var.keg_virt_acl_mode

  dns_label           = var.keg_virt_dns_label

  namespace = merge(
    var.keg_virt_namespace,
    {
      additional: {
        topics: concat(
          length(var.keg_virt_namespace_additional_topics.exact) > 0 ? [{
            exact_list = {
              conflict   = var.keg_virt_namespace_additional_topics.exact_conflict,
              exact_list = var.keg_virt_namespace_additional_topics.exact
            }
          }] : [],
          length(var.keg_virt_namespace_additional_topics.glob) > 0 ? [{
            glob = {
              conflict   = var.keg_virt_namespace_additional_topics.glob_conflict,
              glob = var.keg_virt_namespace_additional_topics.glob
            }
          }] : []
        ),
        consumer_groups: concat(
          length(var.keg_virt_namespace_additional_consumer_groups.exact) > 0 ? [{
            exact_list = {
              exact_list = var.keg_virt_namespace_additional_consumer_groups.exact
            }
          }] : [],
          length(var.keg_virt_namespace_additional_consumer_groups.glob) > 0 ? [{
            glob = {
              glob = var.keg_virt_namespace_additional_consumer_groups.glob
            }
          }] : []
        )
      }
    }
  )
}

resource "konnect_event_gateway_cluster_policy_acls" "my_eventgatewayclusterpolicyacls" {
  condition = "context.auth.principal.name == \"this-user\""
  config = {
    rules = [
      {
        action = "deny"
        operations = [
          {
            name = "describe_configs"
          }
        ]
        resource_names = [
          {
            match = "...my_match..."
          }
        ]
        resource_type = "transactional_id"
      }
    ]
  }
  description = "...my_description..."
  enabled     = false
  gateway_id  = "9524ec7d-36d9-465d-a8c5-83a3c9390458"
  labels = {
    key = "value"
  }
  name               = "...my_name..."
  virtual_cluster_id = "4a444990-e7d1-4dfb-b2bf-2d8e113d1b6e"
}

resource "konnect_event_gateway_listener" "my_eventgatewaylistener" {
  addresses = [
    "..."
  ]
  description = "...my_description..."
  gateway_id  = "9524ec7d-36d9-465d-a8c5-83a3c9390458"
  labels = {
    key = "value"
  }
  name = "...my_name..."
  ports = [
    "..."
  ]
}

resource "konnect_event_gateway_listener_policy_forward_to_virtual_cluster" "my_eventgatewaylistenerpolicyforwardtovirtualcluster" {
  config = {
    sni = {
      advertised_port = 61579
      broker_host_format = {
        type = "per_cluster_suffix"
      }
      sni_suffix = ".example.com"
    }
  }
  description = "...my_description..."
  enabled     = false
  gateway_id  = "9524ec7d-36d9-465d-a8c5-83a3c9390458"
  labels = {
    key = "value"
  }
  listener_id = "bdaf2651-42bc-48ec-b29f-f4890f7f07fc"
  name        = "...my_name..."
}

resource "konnect_event_gateway_produce_policy_modify_headers" "my_eventgatewayproducepolicymodifyheaders" {
  condition = "record.value.content.foo.bar == \"a-value\""
  config = {
    actions = [
      {
        remove = {
          key = "...my_key..."
        }
      }
    ]
  }
  description = "...my_description..."
  enabled     = true
  gateway_id  = "9524ec7d-36d9-465d-a8c5-83a3c9390458"
  labels = {
    key = "value"
  }
  name               = "...my_name..."
  parent_policy_id   = "72c5778e-34a9-4e94-8979-28eb503453b5"
  virtual_cluster_id = "d146afe4-4af6-420a-9a5b-d37b93117501"
}