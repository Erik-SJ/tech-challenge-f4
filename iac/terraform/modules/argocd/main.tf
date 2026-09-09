resource "kubernetes_namespace" "argocd" {

  metadata {
    name = "argocd"
  }

}
resource "helm_release" "argocd" {

  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.8.2"

  namespace = kubernetes_namespace.argocd.metadata[0].name

  create_namespace = false

  values = [
    file("${path.module}/values.yaml")
  ]

  wait    = true
  timeout = 600
  atomic  = true

  depends_on = [
    kubernetes_namespace.argocd
  ]

}
