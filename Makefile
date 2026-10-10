.DEFAULT_GOAL := run

setup:
	mkdir -p quarantine

run: setup
	bash antivirusd.sh watched quarantine 5

restore: setup
	bash restore.sh watched quarantine
