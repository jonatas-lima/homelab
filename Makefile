.PHONY: help deploy destroy plan
.DEFAULT_GOAL := help

# Default LDAP username for authentication
LDAP_USERNAME ?= $(USER)

# Load environment variables
define load_env
	@if [ -f profile.sh ]; then \
		echo "Loading profile.sh..."; \
		source profile.sh $(LDAP_USERNAME); \
	else \
		echo "Warning: profile.sh not found. Copy profile.sample.sh to profile.sh and configure it."; \
	fi
	@if [ -f private.sh ]; then \
		echo "Loading private.sh..."; \
		source private.sh; \
	else \
		echo "Warning: private.sh not found. Copy private.sample.sh to private.sh and configure it."; \
	fi
endef

# Helper function to run terraform commands
define terraform_cmd
	cd terraform/$(1) && \
	bash -c "source ../../profile.sh $(LDAP_USERNAME) && source ../../private.sh && terraform $(2)"
endef

help: ## Show this help message
	@echo "Homelab Infrastructure Management"
	@echo "Usage: make [target] [LDAP_USERNAME=your-username]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

config: ## Copy sample configuration files to working files
	@echo "Setting up configuration files..."
	@if [ ! -f profile.sh ]; then \
		echo "Copying profile.sample.sh to profile.sh..."; \
		cp profile.sample.sh profile.sh; \
		echo "[OK] profile.sh created from sample"; \
	else \
		echo "[SKIP] profile.sh already exists, skipping"; \
	fi
	@if [ ! -f private.sh ]; then \
		echo "Copying private.sample.sh to private.sh..."; \
		cp private.sample.sh private.sh; \
		echo "[OK] private.sh created from sample"; \
	else \
		echo "[SKIP] private.sh already exists, skipping"; \
	fi
	@echo ""
	@echo "Next steps:"
	@echo "1. Edit profile.sh with your LDAP username and configuration"
	@echo "2. Edit private.sh with your LDAP password"
	@echo "3. Run 'make init' to initialize terraform modules"

init: ## Initialize all terraform modules
	@echo "Initializing all terraform modules..."
	@$(MAKE) init-incus
	@$(MAKE) init-infra
	@$(MAKE) init-infra-services
	@$(MAKE) init-vault
	@$(MAKE) init-dns
	@$(MAKE) init-kubernetes-crds
	@$(MAKE) init-kubernetes-core
	@$(MAKE) init-kubernetes-services

init-incus: ## Initialize Incus terraform module
	@echo "Initializing Incus terraform module..."
	$(call terraform_cmd,000-incus,init)

init-infra: ## Initialize DNS infrastructure terraform module
	@echo "Initializing DNS infrastructure terraform module..."
	$(call terraform_cmd,001-infra,init)

init-infra-services: ## Initialize infrastructure services terraform module
	@echo "Initializing infrastructure services terraform module..."
	$(call terraform_cmd,002-infra-services,init)

init-vault: ## Initialize Vault terraform module
	@echo "Initializing Vault terraform module..."
	$(call terraform_cmd,003-vault,init)

init-dns: ## Initialize DNS records terraform module
	@echo "Initializing DNS records terraform module..."
	$(call terraform_cmd,005-dns,init)

init-kubernetes-crds: ## Initialize Kubernetes CRDs terraform module
	@echo "Initializing Kubernetes CRDs terraform module..."
	$(call terraform_cmd,011-kubernetes-crds,init)

init-kubernetes-core: ## Initialize Kubernetes core terraform module
	@echo "Initializing Kubernetes core terraform module..."
	$(call terraform_cmd,012-kubernetes-core,init)

init-kubernetes-services: ## Initialize Kubernetes services terraform module
	@echo "Initializing Kubernetes services terraform module..."
	$(call terraform_cmd,013-kubernetes-services,init)

deploy: ## Deploy all infrastructure in correct order
	@echo "Deploying all infrastructure..."
	@$(MAKE) incus
	@$(MAKE) infra
	@$(MAKE) infra-services
	@$(MAKE) vault
	@$(MAKE) dns
	@$(MAKE) kubernetes-crds
	@$(MAKE) kubernetes-core
	@$(MAKE) kubernetes-services

incus: ## Deploy Incus network and profile setup
	@echo "Deploying Incus infrastructure..."
	$(call terraform_cmd,000-incus,apply)

infra: ## Deploy DNS infrastructure
	@echo "Deploying DNS infrastructure..."
	$(call terraform_cmd,001-infra,apply)

infra-services: ## Deploy GLAuth LDAP and Vault services
	@echo "Deploying infrastructure services..."
	$(call terraform_cmd,002-infra-services,apply)

vault: ## Deploy Vault configuration and policies
	@echo "Deploying Vault configuration..."
	$(call terraform_cmd,003-vault,apply)

dns: ## Deploy DNS records for services
	@echo "Deploying DNS records..."
	$(call terraform_cmd,005-dns,apply)

kubernetes-crds: ## Deploy Kubernetes Custom Resource Definitions
	@echo "Deploying Kubernetes CRDs..."
	$(call terraform_cmd,011-kubernetes-crds,apply)

kubernetes-core: ## Deploy core Kubernetes components
	@echo "Deploying core Kubernetes components..."
	$(call terraform_cmd,012-kubernetes-core,apply)

kubernetes-services: ## Deploy Kubernetes services and ingresses
	@echo "Deploying Kubernetes services..."
	$(call terraform_cmd,013-kubernetes-services,apply)

destroy: ## Destroy all infrastructure (in reverse order)
	@echo "Destroying all infrastructure..."
	@$(MAKE) destroy-kubernetes-services
	@$(MAKE) destroy-kubernetes-core
	@$(MAKE) destroy-kubernetes-crds
	@$(MAKE) destroy-dns
	@$(MAKE) destroy-vault
	@$(MAKE) destroy-infra-services
	@$(MAKE) destroy-infra
	@$(MAKE) destroy-incus

destroy-kubernetes-services: ## Destroy Kubernetes services and ingresses
	@echo "Destroying Kubernetes services..."
	$(call terraform_cmd,013-kubernetes-services,destroy)

destroy-kubernetes-core: ## Destroy core Kubernetes components
	@echo "Destroying core Kubernetes components..."
	$(call terraform_cmd,012-kubernetes-core,destroy)

destroy-kubernetes-crds: ## Destroy Kubernetes Custom Resource Definitions
	@echo "Destroying Kubernetes CRDs..."
	$(call terraform_cmd,011-kubernetes-crds,destroy)

destroy-dns: ## Destroy DNS records
	@echo "Destroying DNS records..."
	$(call terraform_cmd,005-dns,destroy)

destroy-vault: ## Destroy Vault configuration
	@echo "Destroying Vault configuration..."
	$(call terraform_cmd,003-vault,destroy)

destroy-infra-services: ## Destroy infrastructure services
	@echo "Destroying infrastructure services..."
	$(call terraform_cmd,002-infra-services,destroy)

destroy-infra: ## Destroy DNS infrastructure
	@echo "Destroying DNS infrastructure..."
	$(call terraform_cmd,001-infra,destroy)

destroy-incus: ## Destroy Incus infrastructure
	@echo "Destroying Incus infrastructure..."
	$(call terraform_cmd,000-incus,destroy)

check-config: ## Check if configuration files exist
	@echo "Checking configuration files..."
	@if [ ! -f profile.sh ]; then \
		echo "[ERROR] profile.sh not found. Copy profile.sample.sh to profile.sh and configure it."; \
		exit 1; \
	else \
		echo "[OK] profile.sh found"; \
	fi
	@if [ ! -f private.sh ]; then \
		echo "[ERROR] private.sh not found. Copy private.sample.sh to private.sh and configure it."; \
		exit 1; \
	else \
		echo "[OK] private.sh found"; \
	fi
