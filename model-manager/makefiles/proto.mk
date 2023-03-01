.PHONY: clean clean-build clean-pyc clean-test clean-proto-build publish-proto build-proto compile-proto install
.DEFAULT_GOAL := 

SHELL=/bin/bash
PROJECT = model_manager
ROOT_DIR = $(PWD)
PROJECT_DIR = $(ROOT_DIR)/$(PROJECT)
MAKE_DIR = $(ROOT_DIR)/makefiles
PYTHON = python3
PIP = pip3
TELOS = telos
MAKE = make
AZURE_ARTIFACT_USERNAME = sneo
AZURE_ARTIFACT_PASSWORD = hpvgr47fiidfau7chvt6poznw73hvvgmg2nr7otfmdnmnnlvzmvq
AZURE_ARTIFACT_BASE_URL = https://$(AZURE_ARTIFACT_USERNAME):$(AZURE_ARTIFACT_PASSWORD)@pkgs.dev.azure.com/relianceJio/RelianceJio/_packaging/$(TELOS)/pypi
AZURE_ARTIFACT_INDEX_URL = $(AZURE_ARTIFACT_BASE_URL)/simple/
AZURE_ARTIFACT_REPOSITORY_URL = $(AZURE_ARTIFACT_BASE_URL)/upload/
TWINE = twine
PROTO_PATH = $(PROJECT_DIR)/proto
PROTO_BUILD_PATH = $(ROOT_DIR)/build_proto
PROTO_BUILD_SCRIPT = $(MAKE_DIR)/compile_proto.py
GOOGLEAPIS_GIT_REPO = https://fuchsia.googlesource.com/third_party/googleapis
GOOGLE = google
GOOGLEAPIS_PROTO_PATH = $(ROOT_DIR)/googleapis/$(GOOGLE)/api
PROTO_GOOGLE = $(PROTO_PATH)/$(GOOGLE)
PROTO_GOOGLE_API = $(PROTO_GOOGLE)/api
MAKEFILE_ROOT = $(ROOT_DIR)/Makefile
MAKEFILE_PROTO = $(MAKE_DIR)/proto.mk
MAKE_ROOT = @$(MAKE) -C $(ROOT_DIR) -f $(MAKEFILE_ROOT)
MAKE_PROTO = @$(MAKE) -C $(MAKE_DIR) -f $(MAKEFILE_PROTO)
SHELL=/bin/bash  # Need to specify bash in order for conda activate to work.
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate

compile-proto: install
	$(shell mkdir $(PROTO_BUILD_PATH))
	bash -c "$(CONDA_ACTIVATE) $(PROJECT); $(PYTHON) $(PROTO_BUILD_SCRIPT) --protopath $(PROTO_PATH) --pythonpath $(PROTO_BUILD_PATH)"
	$(MAKE_PROTO) clean-proto-build PROJECT_DIR=$(PROJECT_DIR)

install: clean $(PROTO_PATH)
	$(shell cd $(ROOT_DIR); git clone $(GOOGLEAPIS_GIT_REPO);)
	mkdir -p $(PROTO_GOOGLE_API) && cp -R $(GOOGLEAPIS_PROTO_PATH)/annotations.proto $(GOOGLEAPIS_PROTO_PATH)/http.proto $(PROTO_GOOGLE_API)

publish-proto: build-proto
	$(TWINE) upload $(PROTO_BUILD_PATH)/dist/* --repository-url $(AZURE_ARTIFACT_REPOSITORY_URL) -u $(AZURE_ARTIFACT_USERNAME) -p $(AZURE_ARTIFACT_PASSWORD)
	$(MAKE_ROOT) clean

build-proto: compile-proto
	bash -c "cd $(PROTO_BUILD_PATH); $(PYTHON) setup.py sdist bdist_wheel"

clean-proto-build: ## remove build artifacts
	find $(PROJECT_DIR)/. -name '$(GOOGLE)' -exec rm -fr {} +
	