update: ## run nix-update to fetch latest tag
	nix run 'github:Mic92/nix-update' -- --flake pixi --commit

-include .task.mk
PHONIFY=true
$(if $(wildcard .task.mk),,.task.mk: ; curl -fsSL https://raw.githubusercontent.com/daylinmorgan/task.mk/v23.1.2/task.mk -o .task.mk)
