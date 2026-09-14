resource "kubernetes_manifest" "root_app" {

  manifest = yamldecode(
    file("${path.module}/../../../../gitops/bootstrap/root-app.yaml")
  )

  depends_on = [
    kubernetes_manifest.argocd_project
  ]

}
