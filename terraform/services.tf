data "aws_secretsmanager_secret_version" "sealed_secrets_keys" {
  secret_id = "sealed-secrets-keys"
}

locals {
  sealed_secrets_keys = jsondecode(data.aws_secretsmanager_secret_version.sealed_secrets_keys.secret_string)
}

resource "kubernetes_secret" "sealed-secrets-key-1" {
  metadata {
    generate_name = "sealed-secrets-key"
    namespace = "kube-system"

    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }

  data = {
    "tls.crt" = base64decode(local.sealed_secrets_keys.sealed_secrets_key_01_crt)
    "tls.key" = base64decode(local.sealed_secrets_keys.sealed_secrets_key_01_key)
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "sealed-secrets-key-2" {
  metadata {
    generate_name = "sealed-secrets-key"
    namespace = "kube-system"

    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }

  data = {
    "tls.crt" = base64decode(local.sealed_secrets_keys.sealed_secrets_key_02_crt)
    "tls.key" = base64decode(local.sealed_secrets_keys.sealed_secrets_key_02_key)
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "sealed-secrets-key-3" {
  metadata {
    generate_name = "sealed-secrets-key"
    namespace = "kube-system"

    labels = {
      "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
    }
  }

  data = {
    "tls.crt" = base64decode(local.sealed_secrets_keys.sealed_secrets_key_03_crt)
    "tls.key" = base64decode(local.sealed_secrets_keys.sealed_secrets_key_03_key)
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_namespace" "flux" {
  metadata {
    name = "flux"
  }
}

resource "helm_release" "flux" {
  name       = "flux"
  namespace  = kubernetes_namespace.flux.metadata[0].name
  repository = "https://charts.fluxcd.io"
  chart      = "flux"
  version    = "1.5.0"
}

resource "helm_release" "helm_operator" {
  name       = "helm-operator"
  namespace  = kubernetes_namespace.flux.metadata[0].name
  repository = "https://charts.fluxcd.io"
  chart      = "helm-operator"
  version    = "1.2.0"

  set {
    name  = "helm.versions"
    value = "v3"
  }
}

# resource "kubernetes_namespace" "argo_cd" {
#   metadata {
#     name = "argo-cd"
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "argo-cd"
#   namespace  = kubernetes_namespace.argo_cd.metadata[0].name
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   version    = "2.8.0"
# }

# resource "kubernetes_manifest" "argocd_application" {
#   provider = kubernetes-alpha

#   manifest = {
#     "apiVersion" = "argoproj.io/v1alpha1"
#     "kind" = "Application"
#     "metadata" = {
#       "name" = "cluster-services"
#       "namespace" = kubernetes_namespace.argo_cd.metadata[0].name
#     }
#     "spec" = {
#       "destination" = {
#         "server" =  "https://kubernetes.default.svc"
#         "namespace" = kubernetes_namespace.argo_cd.metadata[0].name
#       }
#       "project" = "default"
#       "source" = {
#         "directory" = {
#           "recurse" = true
#         }
#         "repoURL" = "https://github.com/l0ck3/experimental-clusters-config.git"
#         "targetRevision" = "HEAD"
#         "path" = "services"
#       }
#       "syncPolicy" = {
#         "automated" = {
#           "prune" = true
#           "selfHeal" = true
#         }
#       }
#     }
#   }
# }
