PHP Unit docs

This is just a demo. This is not the droid you are looking for.

# Background

This tries to utilize a custom theme but otherwise depend on the
https://github.com/TYPO3-Documentation/render-guides project
for their excellent phpdocumentor-guides integration.

# Installation

## WITH DOCKER (recommended)

* `make docker-build`
* `make docker-docs`
* for debugging: `make docker-enter`

## LOCALLY (also uses docker for PHP)

(TODO)

* `make install`
* `make docs`

## NOTE

Please note that the PHP FQCN for the theme is still called
`T3Docs\Typo3DocsTheme\` because that namespace is hardwired
into some other dependencies of the `render-guides` TYPO3
parent project.
