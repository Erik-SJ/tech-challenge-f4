resource "kubernetes_manifest" "argocd_project" {

  manifest = yamldecode(
    file("${path.module}/../../../../gitops/argocd/project.yaml")
  )

  field_manager {
    force_conflicts = true
  }

}
