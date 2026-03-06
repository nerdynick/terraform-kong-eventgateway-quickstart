# Kong Event Gateway (KEG) Quick Start Module

A simple Terrform module to spin up the basic resources for a secure-by-default Kong Event Gateway.

This only created the needed resources within Kong Konnect. 
It will not spin up any form of a Kafka Cluster or deploy the actual Kong Gateway Instance.
As both of those resources are highly dynamic to the individual environment, such as Docker, VM, or K8s based deployments or Confluent or AWS MSK cloud deployments.

If that is something you'd also like to preform, checkout one of the following child modules:

- [nerdynick/terraform-kong-eventgateway-gettingstarted](https://github.com/nerdynick/terraform-kong-eventgateway-gettingstarted) - 
  A Terraform recreation of the Kong Event Gateway BASH scripted Getting Started. 
  This deployes a basic 3 node Kafka Cluster and a single Event Gateway via Docker.

## PreReqs

- You will need, of course, a Kong Cloud/Konnect account with a valid Org
- Either a Personal Access Token (PAT) or a System Account Access Token (SPAT)

Within the Env that will be executing the Terraform script(s), you will need to define the following ENV Vars:

- `KONNECT_TOKEN=<PAT>` or `KONNECT_SPAT=<SPAT>`
- Optionally `KONNECT_SERVER_URL=<Geo-Regional-URL>`, if not defined it will default to the global API