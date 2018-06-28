.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help
PACKAGE_NAME=truc
define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

define ANNOUNCE_BODY
Makefile help page for the $(PACKAGE_NAME).

Typical workflow is:

- make dev
- make style check test  # or make sct
- make dists
- make pypi

Here are the list of all available commands:

endef
export ANNOUNCE_BODY

BROWSER := python3 -c "$$BROWSER_PYSCRIPT"

help:
	@echo "$$ANNOUNCE_BODY"
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)


clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: toto tata ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

dev:  ## setup dev environment
	pipenv install --dev
	pipenv run pip install -e .

lint: ## check style with flake8
	pipenv run flake8 pya tests

test: ## run tests quickly with the default Python
	pipenv run py.test

test-all: ## run tests on every Python version with tox
	pipenv run tox

coverage: ## check code coverage quickly with the default Python
	pipenv run coverage run --source pya -m pytest
	pipenv run coverage report -m
	pipenv run coverage html
	$(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs
	rm -f docs/pya.rst
	rm -f docs/modules.rst
	pipenv run sphinx-apidoc -o docs/ pya
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(BROWSER) docs/_build/html/index.html

servedocs: docs ## compile the docs watching for changes
	watchmedo shell-command -p '*.rst' -c '$(MAKE) -C docs html' -R -D .

release: dist ## package and upload a release
	pipenv run twine upload dist/*

dist: clean ## builds source and wheel package
	pipenv run python setup.py sdist
	pipenv run python setup.py bdist_wheel
	ls -l dist

install: clean ## install the package to the active Python's site-packages
	pipenv run python setup.py install
