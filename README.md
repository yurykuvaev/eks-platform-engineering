# EKS Platform Engineering

> A reproducible EKS + ArgoCD lab — Terraform-provisioned cluster, GitOps delivery, real screenshots from a debugging session.

A hands-on portfolio piece on **Amazon EKS**: Terraform-provisioned infrastructure and GitOps delivery with ArgoCD, with the workloads it reconciles living in a separate repo.

**Companion repo:** [`k8s-gitops-apps`](https://github.com/yurykuvaev/k8s-gitops-apps) — application manifests continuously reconciled by ArgoCD.

**Larger sibling project:** [`terrascale-platform`](https://github.com/yurykuvaev/terrascale-platform) — multi-environment EKS platform with Terragrunt, observability, secrets, autoscaling, and ADRs.

---

## What's in here

[**Project 01 — EKS + ArgoCD**](./01-eks-argocd/README.md): a Terraform-provisioned EKS cluster bootstrapped with ArgoCD, the `guestbook` application reconciled from Git, and a documented rollback session.

---

## Tech Stack

**Cloud & infra** — AWS (EKS, VPC, IAM, KMS), Terraform 1.9+, `terraform-aws-modules`
**Kubernetes** — EKS 1.30, Helm, ArgoCD, Kustomize
**Patterns** — GitOps, IaC, IRSA, least-privilege IAM, self-healing sync, drift detection

---

## Architecture

```
GitHub: yurykuvaev/eks-platform-engineering       GitHub: yurykuvaev/k8s-gitops-apps
(infrastructure as code)                           (application manifests)
|                                                   |
| terraform apply                                   | watched by ArgoCD
v                                                   |
+-------------------------------------+             |
|  AWS EKS Cluster (k8s-lab, v1.30)   |             |
|  VPC / 3 AZs / KMS / OIDC / IRSA    |             |
|                                     |             |
|  +--------------+  syncs from Git   |             |
|  |  ArgoCD      |<-------------------+-------------+
|  +------+-------+                   |
|         v                           |
|  [ workloads reconciled from Git ]  |
+-------------------------------------+
```

---

## Preview

![ArgoCD Tree View](./01-eks-argocd/docs/screenshots/02-argocd-tree-view.png)

ArgoCD reconciling the `guestbook` application from Git, with a visible rollback history (`rev:1` → `rev:2`) from a real debugging session documented in the [Project 01 README](./01-eks-argocd/README.md#lessons-learned).

---

## What This Demonstrates

- **Infrastructure as Code** — cluster reproducible from `terraform apply`; teardown via `terraform destroy`
- **GitOps delivery** — no manual `kubectl apply` in normal operation; Git is the source of truth
- **Separation of concerns** — platform repo (this) vs. application repo ([`k8s-gitops-apps`](https://github.com/yurykuvaev/k8s-gitops-apps))
- **Self-healing & drift detection** — manual changes in-cluster are reverted to the Git-declared state
- **Cost-aware lab design** — ~$0.20/hour, torn down between sessions; lessons learned documented alongside the project

---

## Running It

The project is self-contained with its own README and `terraform apply` / `terraform destroy` flow. See [**Project 01 — EKS + ArgoCD**](./01-eks-argocd/README.md).

Prerequisites: AWS account, `aws` CLI, `terraform` ≥ 1.9, `kubectl`, `helm`.

---

## About

Built by [Yury Kuvaev](https://github.com/yurykuvaev) as a public, reproducible record of platform engineering work — Terraform, manifests, lessons learned, and real debugging screenshots instead of polished demos.

Contact: kuvaevdevops@gmail.com
