output "namespace" {
  description = "Namespace onde o ArgoCD foi instalado"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  description = "Nome do Helm release do ArgoCD"
  value       = helm_release.argocd.name
}
