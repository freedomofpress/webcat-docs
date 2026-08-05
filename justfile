# Serve the mdbook with auto-open
dev:
    cd webcat-documentation && mdbook serve --open

alias serve := dev

# Build the mdbook project
build:
    cd webcat-documentation && mdbook build

# run linters, checking for valid links
lint:
  # check mdbook syntax first
  just build
  # skipping extra check for broken links in any markdown document
  # fd -t f -e md -e mdx -X markdown-link-check
