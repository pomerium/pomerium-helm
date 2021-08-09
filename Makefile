GO ?= "go"

# Generate helm docs
.PHONY: docs
docs:
	@echo "==> $@"
	@cd /tmp; GO111MODULE=on $(GO) get github.com/norwoodj/helm-docs/cmd/helm-docs
	helm-docs
