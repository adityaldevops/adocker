.PHONY: clean clean-build clean-pyc clean-test help lint lint/flake8 test test-all run env-setup
.DEFAULT_GOAL := help

PROJECT = model_manager
ROOT_DIR = $(PWD)
PROJECT_DIR = $(ROOT_DIR)/$(PROJECT)
MAKE_DIR = $(ROOT_DIR)/makefiles
CONDA_ENV_CONFIG_FILE = $(MAKE_DIR)/conda_env_config.yml
ENV_CONFIG_FILE = $(ROOT_DIR)/local.env
PROJECT = model_manager
CONDA_ENV = $(shell conda env list | grep $(PROJECT))
SHELL=/bin/bash  # Need to specify bash in order for conda activate to work.
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate
MAKEFILE_PROTO = $(MAKE_DIR)/proto.mk
MAKE_PROTO = @$(MAKE) -C $(MAKE_DIR) -f $(MAKEFILE_PROTO)

help:
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	find $(ROOT_DIR)/. -name 'build_proto' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name 'dist' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name '*.eggs' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name '*.egg-info' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name '*.egg' -exec rm -fr {} +
	$(MAKE_PROTO) clean-proto-build PROJECT_DIR=$(PROJECT_DIR)

clean-pyc: ## remove Python file artifacts
	find $(ROOT_DIR)/. -name '*.pyc' -exec rm -f {} +
	find $(ROOT_DIR)/. -name '*.pyo' -exec rm -f {} +
	find $(ROOT_DIR)/. -name '*~' -exec rm -f {} +
	find $(ROOT_DIR)/. -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	find $(ROOT_DIR)/. -name '*.tox' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name '*.coverage' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name 'htmlcov' -exec rm -fr {} +
	find $(ROOT_DIR)/. -name '*.pytest_cache' -exec rm -fr {} +

lint/flake8: ## check style with flake8
	bash -c "$(CONDA_ACTIVATE) $(PROJECT); flake8 $(PROJECT_DIR) $(ROOT_DIR)/tests"

lint/protolint: ## check style with protolint
	$(shell protolint lint $(PROJECT_DIR))

lint/install:
	brew tap yoheimuta/protolint
	brew install protolint

lint: lint/flake8 lint/install lint/protolint ## check style

test: ## run tests quickly with the default Python
	pytest

test-all: ## run tests on every Python version with tox
	tox

run: env-setup
	bash -c "$(CONDA_ACTIVATE) $(PROJECT); source $(ENV_CONFIG_FILE);"

env-setup: $(ROOT_DIR)/pyproject.toml clean
	bash -c "if [ -z '$(CONDA_ENV)' ]; then conda env create -f $(CONDA_ENV_CONFIG_FILE) -n $(PROJECT); fi"
	bash -c "$(CONDA_ACTIVATE) $(PROJECT); poetry install"
