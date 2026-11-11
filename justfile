# Serve the mdbook with auto-open
dev:
    cd webcat-documentation && mdbook serve --open

alias serve := dev

# Build the mdbook project
build:
    cd webcat-documentation && mdbook build
    just full

# Concatenate every page, in table-of-contents order, into one Markdown file (webcat#183)
full:
    cd webcat-documentation && for f in $(grep -oE '\./[^)]+\.md' src/SUMMARY.md); do printf '\n\n<!-- %s -->\n\n' "$f"; cat "src/$f"; done > book/html/book.md && ln -sf book.md book/html/llms.txt

# run linters, checking for valid links
lint:
  # check mdbook syntax first
  just build
  # skipping extra check for broken links in any markdown document
  # fd -t f -e md -e mdx -X markdown-link-check
