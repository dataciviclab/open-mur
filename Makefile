# open-uni — Intelligence sulle università italiane
TOOLKIT = toolkit

DATASETS := $(shell find datasets -name dataset.yml 2>/dev/null | sort)
SUPPORT  := $(shell find support -name dataset.yml 2>/dev/null | sort)

.PHONY: check run run-all run-batch seeds clean clean-runs help

check:
	@for f in $(SUPPORT) $(DATASETS); do \
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

# Un solo processo per tutti i dataset: evita ~33s di import per config in CI.
run-all:
	@mkdir -p .tmp
	@find support -name dataset.yml | sort > .tmp/batch_all.txt
	@find datasets -name dataset.yml | sort >> .tmp/batch_all.txt
	@echo "📦 $$(wc -l < .tmp/batch_all.txt | tr -d ' ') config (support + datasets)"
	$(TOOLKIT) run --batch .tmp/batch_all.txt

# Batch selettivo post-merge: esegue solo i dataset toccati (batch.txt dal workflow).
run-batch:
	@if [ -s batch.txt ]; then \
		$(TOOLKIT) run --batch batch.txt; \
	else \
		echo "Nessun dataset da processare"; \
	fi

clean:
	rm -rf out/data/_runs out/data/probe out/data/raw out/data/clean out/data/mart out/data/cross .tmp/

clean-runs:
	rm -rf out/data/_runs/

help:
	@grep -E '^[a-zA-Z_-]+:' Makefile | sort
