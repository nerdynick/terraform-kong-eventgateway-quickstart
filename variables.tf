# Event Gateway Variables
variable "keg_name" {
    type = string
    default = "event-gateway-quickstart"
    description = "Name to give the Event Gateway"
}

variable "keg_desc" {
    type = string
    default = "${var.gateway_name} Quick Start Event Gateway"
    description = "Description to give the newly created Event Gateway"
}

variable "keg_labels" {
    type = map(string)
    default = {
        quickstart: "true"
    }
    description = "Labels to set against the Event Gateway"
}

# Single Backend Kafka Cluster Variables
variable "keg_backend_name" {
    type = string
    default = "event-gateway-quickstart-backend-cluster"
    description = "Name to give to your Kafka Cluster sitting behind this event gateway"
}

variable "keg_backend_desc" {
    type = string
    default = "${var.keg_backend_name} Quick Start Kafka Cluster"
    description = "Description of the Kafka Cluster sitting behind this event gateway"
}

variable "keg_backend_labels" {
    type = map(string)
    default = {
      quickstart: "true"
    }
    description = "Labels to apply to the Event Gateway Backend Cluster"
}

variable "keg_backend_bootsrap_servers" {
    type = list(string)
    description = "One of more <broker>:<port> combinations representing each Kafka Broker participating or a single address referencing a LB/DNS RoundRobin"
}

variable "keg_backend_authentication" {
    type = object({
      anonymous = map(any),
      sasl_plain = object({
        username: string,
        password: string
      }),
      sasl_scram = object({
        algorithm: string, # One of "sha256", "sha512"
        username: string,
        password: string
      })
    })
    sensitive = true
    description = "Credentials for the Event Gateway to use when connecting to the backend Kafka Cluster. Mostly for use to retreive metadata about the cluster to facilitate proxying of requests."
    
    validation {
        condition = (
            var.keg_backend_authentication.anonymous != null || var.keg_backend_authentication.sasl_plain != null || var.keg_backend_authentication.sasl_scram != null && 
            (var.keg_backend_authentication.sasl_scram != null ? var.keg_backend_authentication.sasl_scram.algorithm == "sha256" || var.keg_backend_authentication.sasl_scram.algorithm == "sha512" : true)
        )
        error_message = "One of Anonymous, SASL_Plain, or SASL_Scram but be defined and if using SCRAM one of sha256 or sha512 must be used for the Algorithm"
    }
}

variable "keg_backend_metadata_refresh_interval" {
    type = number
    default = 60
    description = "How often should the Event Gateway refresh its metadata, aka state of the world, about the Backend Kafka Cluster, in seconds"
}

variable "keg_backend_tls_enabled" {
    type = bool
    default = true
    description = "Explicit flag to enable to disable TLS support. The final value will be overriden to true if any other TLS settings are configured."
}

variable "keg_backend_tls_client_identity" {
    type = object({
        certificate: string,
        key: string
    })
    default = null
    description = "The Client TLS Certificate in PEM format for mTLS based Authentication"
    sensitive = true
}

variable "keg_backend_tls_ca_bundle" {
    type = string
    default = null
    description = "Certificate Authroty Bundle for validating the Server Cert against, in PEM format"
}

variable "keg_backend_tls_versions" {
    type = list(string)
    default = ["tls12", "tls13"]
    description = "What TLS versions are allowed"
}

variable "keg_backend_tls_allow_insecure_verify" {
    type = bool
    default = false
    description = "Should we allow insecure/unverified TLS Certs. This is disabled by default to ensure stronger security. But in the case of some self-signed certs or internal PKI systems. It may be required to disable cert verifications."
}

# Single Virtual Cluster Variables
variable "keg_virt_name" {
    type = string
    default = "event-gateway-quickstart-virtualcluster"
    description = "Name to give to your Virtual Kafka Cluster"
}

variable "keg_virt_desc" {
    type = string
    default = "${var.keg_virt_name} Quick Start Kafka Virtual Cluster"
    description = "Description of the Virtual Kafka Cluster"
}

variable "keg_virt_labels" {
    type = map(string)
    default = {
      quickstart: "true"
    }
    description = "Labels to apply to the Virtual Kafka Cluster"
}

variable "keg_virt_authentication" {
    type = object({
      anonymous = map(any),
      sasl_plain = object({
        username: string,
        password: string
      }),
      sasl_scram = object({
        algorithm: string, # One of "sha256", "sha512"
        username: string,
        password: string
      })
    })
    sensitive = true
    description = "Credentials for the Event Gateway to use when connecting to the backend Kafka Cluster. Mostly for use to retreive metadata about the cluster to facilitate proxying of requests."
    
    validation {
        condition = (
            var.keg_backend_authentication.anonymous != null || var.keg_backend_authentication.sasl_plain != null || var.keg_backend_authentication.sasl_scram != null && 
            (var.keg_backend_authentication.sasl_scram != null ? var.keg_backend_authentication.sasl_scram.algorithm == "sha256" || var.keg_backend_authentication.sasl_scram.algorithm == "sha512" : true)
        )
        error_message = "One of Anonymous, SASL_Plain, or SASL_Scram but be defined and if using SCRAM one of sha256 or sha512 must be used for the Algorithm"
    }
}

variable "keg_virt_acl_mode" {
    type = string
    default = "passthrough"
    description = "Configures whether or not ACL policies are enforced on the gateway or at the backend cluster. `enforce_on_gateway` means the gateway enforces its own ACL policies for this virtual cluster and does not forward ACL-related commands to the backend cluster. Note that if there are no ACL policies configured, all access is denied. `passthrough` tells the gateway to forward all ACL-related commands."
    validation {
        condition = (
            var.keg_virt_acl_mode == "enforce_on_gateway" || 
            var.keg_virt_acl_mode == "passthrough"
        )
        error_message = "keg_virt_acl_mode must be one of `enforce_on_gateway` or `passthrough`"
    }
}

variable "keg_virt_dns_label" {
    type = string
    description = "Address of the URI that will be used as the Bootstrap URL for Kafka Clients to connect to this Virtual Cluster. Needed for TLS verification."
}

variable "keg_virt_namespace" {
    type = object({
      mode = string
      prefix = string
    })
    default = null
    validation {
        condition = (
            var.keg_virt_namespace == null || (
                var.keg_virt_namespace.prefix != null && 
                var.keg_virt_namespace.prefix != "" && (
                    var.keg_virt_namespace.mode == "hide_prefix" || 
                    var.keg_virt_namespace.mode == "enforce_prefix"
                )
            )
        )
        error_message = "Namespace Mode must be one of `hide_prefix` or `enforce_prefix` and Prefix must not be null"
    }
}