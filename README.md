# Layered Infrastructure with Terraform Remote State

Two independent Terraform projects that share data through remote state. The network layer creates a security group; the web layer reads its outputs from S3 and deploys a server behind it.

## Structure

```
tf-layered-infra/
+-- network/   # Security group, exposes its ID and port as outputs
+-- web/       # EC2 web server, reads network outputs via terraform_remote_state
```

Each layer has its own state file in S3, with native state locking:

- `tf-layered-infra/network/terraform.tfstate`
- `tf-layered-infra/web/terraform.tfstate`

## Why separate layers?

- **Smaller blast radius**: a mistake in the web layer can't affect the network layer's state.
- **Independent ownership**: different teams can manage different layers.
- **A single source of truth**: the web layer takes both the security group and the port from the network layer, so the firewall and the server can never disagree.

## Usage

Deploy bottom-up:

```bash
cd network && terraform init && terraform apply
cd ../web && terraform init && terraform apply
```

Destroy top-down:

```bash
cd web && terraform destroy
cd ../network && terraform destroy
```

**Order matters.** Terraform tracks dependencies within a project, but not between projects. Destroying the network layer first would fail, because AWS won't delete a security group that a running server still uses.

## What I learned

- (write your own observations here)

## Prerequisites

An S3 state bucket, created by [tf-state-bootstrap](https://github.com/NSDR-A1/tf-state-bootstrap).
