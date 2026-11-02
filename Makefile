# open-uni — Intelligence sulle università italiane
TOOLKIT = toolkit

DATASETS := $(shell find datasets -name dataset.yml 2>/dev/null | sort)
SUPPORT  := $(shell find support -name dataset.yml 2>/dev/null | sort)
COMPOSE  := $(shell find compose -name dataset.yml 2>/dev/null | sort)

.PHONY: check run run-all run-batch compose seeds clean clean-runs help

check:
	@for f in $(SUPPORT) $(DATASETS) $(COMPOSE); do \
		echo "→ $$f"; \
		$(TOOLKIT) run preflight --config "$$f" > /dev/null 2>&1 || exit 1; \
	done
	@echo "✅ All configs valid"

seeds:
	@for f in $(SUPPORT); do \
		echo "=== $$f ==="; \
		$(TOOLKIT) run --config "$$f" || exit 1; \
	done

run:
	@for f in $(DATASETS); do \
		echo "=== $$f ==="; \
		$(TOOLKIT) run --config "$$f" || exit 1; \
	done

run-all: seeds run

# Batch selettivo post-merge: esegue solo i dataset toccati (batch.txt dal workflow).
run-batch:
	@if [ -s batch.txt ]; then \
		$(TOOLKIT) run --batch batch.txt; \
	else \
		echo "Nessun dataset da processare"; \
	fi

# Compose cross-repo (legge i clean pubblicati su GCS di altri repo).
compose:
	@for f in $(COMPOSE); do \
		echo "=== $$f ==="; \
		$(TOOLKIT) run --config "$$f" || exit 1; \
	done

clean:
	rm -rf out/data/_runs out/data/probe out/data/raw out/data/clean out/data/mart out/data/cross .tmp/

clean-runs:
	rm -rf out/data/_runs/

help:
	@grep -E '^[a-zA-Z_-]+:' Makefile | sort
