output "active_key" {
    value = confluent_api_key.kafka-api-key[local.latest_key]
    description = "The current active API Key to be used for new logins. See [Confluent/confluent_api_key](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_api_key) for the expected structure"
}