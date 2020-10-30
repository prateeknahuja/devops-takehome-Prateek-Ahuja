variable "credentials" {
  type        = string
  description = "Location of the credentials keyfile."
}

variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in."
}

variable "region" {
  type        = string
  description = "The region to host the cluster in."
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to create in the GKE"
}

variable "gke_num_nodes" {
  type        = number
  description = "Number of nodes in the NodePool."
}
