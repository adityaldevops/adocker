.PHONY: clean clean-build clean-pyc clean-test install lint lint/flake8 run

ROOT_DIR = $(PWD)
MAKE_DIR = $(ROOT_DIR)/makefiles
MAKEFILE_PROJECT = $(MAKE_DIR)/project.mk
MAKEFILE_PROTO = $(MAKE_DIR)/proto.mk
MAKE_PROJECT = @$(MAKE) -C $(MAKE_DIR) -f $(MAKEFILE_PROJECT)
MAKE_PROTO = @$(MAKE) -C $(MAKE_DIR) -f $(MAKEFILE_PROTO)

run: 
	$(MAKE_PROJECT) run

lint: 
	$(MAKE_PROJECT) lint

test: 
	$(MAKE_PROJECT) test

test-all: 
	$(MAKE_PROJECT) test

clean: 
	$(MAKE_PROJECT) clean

compile-proto: 
	$(MAKE_PROTO) compile-proto
