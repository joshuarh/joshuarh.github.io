:let @q=""
:" quit once we've highlighted every code block
:set nowrapscan hidden paste
qq
/<pre class="src src-
f";
Bf-l
"fyt"
yit
:new
P
:bnext
:only!
:" org-export-to-file escapes html entities
:silent! %s/&amp;/\&/g
:silent! %s/&gt;/>/g
:silent! %s/&lt;/</g
:execute ":write " . tempname()
:silent! %s/\&/&amp;/g
:silent! %s/>/&gt;/g
:silent! %s/</&lt;/g
gg0
dG
:r!pygmentize -O encoding=utf8 -f html -l f %
Gk
Jx
gg0
yG
:bnext
:set paste
cat
0

:write
:bnext
:" get rid of the temporary file
:!rm %
:bdelete!
:" keep highlighting code blocks until there aren't any left
@q
q
@q
:xit
