SHELL = /bin/sh
PATH += :./node_modules/.bin
PROJECT_DIR = $$(pwd)
COFFEESCRIPT = $(wildcard src/coffee/*.coffee)
POST_SOURCES = $(wildcard src/posts/*.org)
POST_TARGETS = $(addprefix posts/,$(notdir $(POST_SOURCES:.org=.html)))

all: node_modules css/style.css js/app.js $(POST_TARGETS) index.html

clean:
	rm -rf *.html css/ js/ posts/ node_modules/

node_modules:
	npm install

css/%.css: node_modules src/stylus/%.styl
	-mkdir css/
	stylus --compress src/stylus/ --out css/
	rm css/_*.css # remove compiled partials
	sqwish "$@" # makes 'filename.min.css'
	mv "$(basename $@).min.css" "$@"

js/app.js: node_modules $(COFFEESCRIPT)
	-mkdir js/
	coffee --join "$@" --compile $(COFFEESCRIPT)
	uglifyjs "$@" --compress --mangle --output "$@"

posts/%.html: src/posts/%.org
	-mkdir -p "$(PROJECT_DIR)/posts/"

	# this MUST be first, as it overwrites the compiled post
	emacs --quick --no-window-system \
		--eval "(require 'package)" \
		--eval "(package-initialize)" \
		--file '$<' \
		--eval "(setq org-export-with-toc nil)" \
		--eval "(setq org-export-with-section-numbers nil)" \
		--eval "(org-export-to-file 'html \"$(PROJECT_DIR)/$@\" nil nil nil t)" \
		--eval "(find-file \"$(PROJECT_DIR)/$@\")" \
		--eval "(insert \"<h1>$(subst -, ,$(*F))</h1>\")" \
		--eval "(beginning-of-buffer)" \
		--eval "(insert-file \"$(PROJECT_DIR)/src/partials/post_start.html\")" \
		--eval "(write-file \"$(PROJECT_DIR)/$@\")" \
		--kill

	vim -s scripts/pygmentize-all-code-blocks.vim "$(PROJECT_DIR)/$@"
	vim -s scripts/asciinema-embed.vim "$(PROJECT_DIR)/$@"

	cat "$(PROJECT_DIR)/src/partials/post_end.html" \
			"$(PROJECT_DIR)/src/partials/footer.html" \
			"$(PROJECT_DIR)/src/partials/end.html" >> '$@'

index.html: src/posts/*.org src/partials/*.html
	cat src/partials/index_start.html > index.html

	echo "<ul id=posts>" >> index.html

	for post in $(POST_TARGETS); do \
		post_name="$$(basename $${post%.*})"; \
		post_title="$$(echo $$post_name | tr '-' ' ')"; \
		post_src="src/posts/$$post_name.org"; \
		post_author_date="$$(git log --format=format:%ai -- $$post_src)"; \
		echo "<li><a href=\"/$$post\">$$post_title <span class=date>$$(date --date=" $$post_author_date " +'%e %B, %Y')</span></a></li>" >> index.html; \
	done

	echo "</ul>" >> index.html

	cat src/partials/footer.html \
	    src/partials/end.html >> index.html
