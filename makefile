SHELL = /bin/sh
PATH += :./node_modules/.bin
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
	stylus src/stylus/ --out css/
	rm css/_*.css # remove compiled partials
	myth "$@" "$@"
	sqwish "$@" -o "$@"

js/app.js: node_modules $(COFFEESCRIPT)
	-mkdir js/
	coffee --join "$@" --compile $(COFFEESCRIPT)
	uglifyjs "$@" --compress --mangle --output "$@"

# also makes posts/%.pdf and posts/%.txt
posts/%.html: src/posts/%.org
	-mkdir -p "$(PWD)/posts/"

	# this MUST be first, as it overwrites the compiled post
	emacs --quick --no-window-system \
		--eval "(require 'package)" \
		--eval "(package-initialize)" \
		--file '$<' \
\
		--eval "(setq org-export-with-toc nil)" \
		--eval "(setq org-export-with-section-numbers nil)" \
		--eval "(setq org-export-with-date nil)" \
		--eval "(org-export-to-file 'html \"$(PWD)/$@\" nil nil nil t)" \
\
		--eval "(cd \"$(PWD)/posts\")" \
		--eval "(org-latex-export-to-pdf)" \
		--eval "(org-ascii-export-to-ascii)" \
\
		--eval "(find-file \"$(PWD)/$@\")" \
		--eval "(insert \"<h1>$(subst -, ,$(*F))</h1>\")" \
		--eval "(insert \"<a href='/posts/$(*F).pdf' target=_blank class=post-download-link title='download as pdf'> pdf </a>\")" \
		--eval "(insert \"<a href='/posts/$(*F).txt' target=_blank class=post-download-link title='download as text'> text </a>\")" \
		--eval "(insert \"<a href='/src/posts/$(*F).org' target=_blank class=post-download-link title='download as org-mode text'> source </a>\")" \
\
		--eval "(beginning-of-buffer)" \
		--eval "(insert-file \"$(PWD)/src/partials/post_start.html\")" \
		--eval "(beginning-of-buffer)" \
		--eval "(insert-file \"$(PWD)/src/partials/head.html\")" \
		--eval "(write-file \"$(PWD)/$@\")" \
		--kill

	# remove the unneeded LaTeX file that was used to make the PDF
	-rm posts/$(*F).tex

	# highlight code blocks if there are any
	if [ -n "$$(grep --only-matching "\<pre class=.src src-" "$(PWD)/$@")" ]; then \
		vim -s scripts/pygmentize-all-code-blocks.vim "$(PWD)/$@"; \
	fi

	# add anchor links to section headers
	if [ -n "$$(grep --only-matching "\<h. id=.sec" "$(PWD)/$@")" ]; then \
		vim -s scripts/add-anchor-links.vim "$(PWD)/$@"; \
	fi

	cat "$(PWD)/src/partials/post_end.html" \
			"$(PWD)/src/partials/footer.html" \
			"$(PWD)/src/partials/end.html" >> '$@'

index.html: src/posts/*.org src/partials/*.html
	cat src/partials/head.html src/partials/index_start.html > index.html

	echo "<ul id=posts>" >> index.html

	# sort posts in last-authored order
	sorted_posts_list=$$(for f in src/posts/*.org; do \
		echo "$$(git log -1 --format=%at $$f) $$f"; \
	done | sort --reverse | cut -d' ' -f2); \
\
	for post in $$sorted_posts_list; do \
		post_name="$$(basename $${post%.*})"; \
		post_title="$$(echo $$post_name | tr '-' ' ')"; \
		post_src="src/posts/$$post_name.org"; \
		post_pdf="posts/$$post_name.pdf"; \
		post_text="posts/$$post_name.txt"; \
		post_html="posts/$$post_name.html"; \
		post_author_date="$$(git log --format=format:%ai -- $$post_src | tail -1)"; \
		echo "<li><a href=\"/$$post_html\">$$post_title</a> \
							<span class=date>$$(date --date=" $$post_author_date " +'%e %B, %Y')</span>\
							<a href=\"/$$post_pdf\" target=_blank class=post-download-link title='download as pdf'> pdf </a> \
							<a href=\"/$$post_text\" target=_blank class=post-download-link title='download as text'> text </a> \
							<a href=\"/$$post_src\" target=_blank class=post-download-link title='download as org-mode text'> source </a> \
					</li>" >> index.html; \
	done

	echo "</ul>" >> index.html

	cat src/partials/footer.html \
			src/partials/end.html >> index.html
