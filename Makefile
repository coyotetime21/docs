TYPST ?= typst
FLAGS := --root . --font-path fonts --ignore-system-fonts
DIR   ?= creds
SRC   := $(DIR)/main.typ
SITE  := build
TITLE ?= креды

.PHONY: pdf watch png all clean fonts site tg

all: pdf png

pdf:
	$(TYPST) compile $(FLAGS) $(SRC) $(DIR)/$(DIR).pdf

watch:
	$(TYPST) watch $(FLAGS) $(SRC) $(DIR)/$(DIR).pdf

png:
	rm -f $(DIR)/slide-*.png
	$(TYPST) compile $(FLAGS) --format png --ppi 144 $(SRC) "$(DIR)/slide-{0p}.png"

site: pdf png
	rm -rf $(SITE)/$(DIR) && mkdir -p $(SITE)/$(DIR)
	cp $(DIR)/$(DIR).pdf $(DIR)/slide-*.png $(SITE)/$(DIR)/
	sh lib/site.sh $(DIR) "$(TITLE)" > $(SITE)/$(DIR)/index.html
	printf '<meta http-equiv="refresh" content="0; url=$(DIR)/">\n' > $(SITE)/index.html

tg:
	for d in tg/*/; do \
		rm -f $$d/slide-*.png; \
		$(TYPST) compile $(FLAGS) --format png --ppi 192 $$d/main.typ "$$d/slide-{0p}.png" || exit 1; \
	done

fonts:
	$(TYPST) fonts $(FLAGS) --variants

clean:
	rm -f $(DIR)/$(DIR).pdf $(DIR)/slide-*.png
	rm -rf $(SITE)
	rm -f tg/*/slide-*.png
