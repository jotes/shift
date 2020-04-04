.PHONY: help setup docs precommit

help: ## Print this message and exit.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 | "sort"}' $(MAKEFILE_LIST)

precommit: ## Run all necessary pre-commit actions and checks.
	@echo "---============ Running pre-commit check ============---"
	
	@echo "| - run goimports (overwrite mode)"
	goimports -e -w .

	@echo "| - run gofmt (overwrite mode)"
	gofmt -w -e -l -s .

	@echo "| - run golangci-lint"
	./bin/golangci-lint run

	@echo "| - run go mod tidy"
	go mod tidy -v
	
	@echo "| - run go mod verify"
	go mod verify

API_DOCS_URL=http://localhost:6060/pkg/github.com/DamianSkrzypczak/shift/
serve-godoc: ## Serve local, API documentation. 
	@echo "---============ Serving (godoc) API documentation  ============---"
	@echo "| - API documentation should be available under ${API_DOCS_URL}"	
	@echo "| - use ctrl + c to quit"	
	@godoc -http=:6060 >/dev/null
serve-godoc-open: _open_api_docs serve-godoc ## "serve-godoc" with auto browser open. 
_open_api_docs: 
	@xdg-open ${API_DOCS_URL} >/dev/null


PROJECT_DOCS_URL=http://localhost:1313/shift/
serve-hugo: ## Serve local, project documentation. 
	@echo "---============ Serving (hugo) Project documentation ============---"
	@echo "| - project documentation should be available under ${PROJECT_DOCS_URL}"	
	@echo "| - use ctrl + c to quit"
	./bin/hugo serve -s docs
serve-hugo-open: _open_proj_docs serve-hugo ## "serve-hugo" with auto browser open. 
_open_proj_docs: 
	@xdg-open ${PROJECT_DOCS_URL} >/dev/null

setup-all: setup-dev setup-doc ## Setup whole development & documentation environment.

setup-dev: ## Setup development environment.  
	@echo "---============ Installing development dependencies ============---"
	
	@echo "| - installing goimports"
	go get golang.org/x/tools/cmd/goimports 
	
	@echo "| - installing golangci-lint (into ./bin)"
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh

	@go mod tidy

setup-doc: _install_api_doc_tools _install_project_doc_tools _install_project_doc_theme ## Setup API & project documentation environment.

_install_api_doc_tools:
	@echo "---============ Installing API documentation dependencies ============---"
	@echo "| - installing godoc (API documentation)"
	go get golang.org/x/tools/cmd/godoc


_install_project_doc_tools:
	@echo "---============ Installing Project documentation dependencies ============---"
	@echo "| - installing hugo (Project documentation)"
	curl -Ls https://github.com/gohugoio/hugo/releases/latest/ \
		| grep "hugo_.*_Linux-64bit.tar.gz" \
		| grep "\".*hugo/releases/download/.*/hugo_[^a-z]*_Linux-64bit.tar.gz\"" -o \
		| xargs -I % curl -sSfL https://github.com% -o /tmp/hugo.tar.gz

	tar -C ./bin/ -zxvf /tmp/hugo.tar.gz hugo > /dev/null || rm /tmp/hugo.tar.gz

_install_project_doc_theme:
	@echo "---============ Installing project documentation theme  ============---"
	@echo "| - installing godoc (API documentation)"
	git clone https://github.com/matcornic/hugo-theme-learn.git ./docs/themes/hugo-theme-learn