# Justfile for Siva's Blog

# Rebuild the entire blog
build:
    emacs --init-directory /home/sivark/emacs-bedrock/ --batch -l publish.el

# Clean up generated HTML files
clean:
    rm -f *.html feed.xml

# Default action is to build
default: build
