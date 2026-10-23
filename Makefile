TYPST ?= typst
FLAGS := --root . --font-path fonts --ignore-system-fonts
DIR   ?= creds
SRC   := $(DIR)/main.typ
SITE  := build
TITLE ?= креды

.PHONY: pdf watch png all clean fonts site

all: pdf png

pdf:
	$(TYPST) compile $(FLAGS) $(SRC) $(DIR)/$(DIR).pdf

watch:
	$(TYPST) watch $(FLAGS) $(SRC) $(DIR)/$(DIR).pdf

png:
	rm -f $(DIR)/slide-*.png
	$(TYPST) compile $(FLAGS) --format png --ppi 144 $(SRC) "$(DIR)/slide-{0p}.png"

# Страница для GitHub Pages: $(SITE)/$(DIR)/ (слайды + PDF), корень ведёт на $(DIR)/
site: pdf png
	rm -rf $(SITE)/$(DIR) && mkdir -p $(SITE)/$(DIR)
	cp $(DIR)/$(DIR).pdf $(DIR)/slide-*.png $(SITE)/$(DIR)/
	sh lib/site.sh $(DIR) "$(TITLE)" > $(SITE)/$(DIR)/index.html
	printf '<meta http-equiv="refresh" content="0; url=$(DIR)/">\n' > $(SITE)/index.html

fonts:
	$(TYPST) fonts $(FLAGS) --variants

clean:
	rm -f $(DIR)/$(DIR).pdf $(DIR)/slide-*.png
	rm -rf $(SITE)
