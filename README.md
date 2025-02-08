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

* `make -B install`
* `make docs`

## NOTE

Please note that the PHP FQCN for the theme is still called
`T3Docs\Typo3DocsTheme\` because that namespace is hardwired
into some other dependencies of the `render-guides` TYPO3
parent project.

## IMPORTANT

Most things are just a copy of render-guides. Notable differences:
 
https://github.com/garvinhicking/unit-guides/commit/159b9343a049282276cde1bc9f9581d22e3f01cc

- Introduces `packages/phpunit-docs-theme/resources/config/phpunit-docs-theme.php`
  (a copy of `typo3-docs-theme.php`)
- Modified templates:
    - packages/phpunit-docs-theme/resources/template/structure/layoutParts/footer.html.twig
      (different footer)
    - packages/phpunit-docs-theme/resources/template/structure/layoutParts/footerAssets.html.twig
      (different footer JS includes)
    - packages/phpunit-docs-theme/resources/template/structure/layoutParts/generalHeaderLinks.html.twig
      (different head JS includes)
    - packages/phpunit-docs-theme/resources/template/structure/layoutParts/linkReferenceModal.html.twig
      (removal of TYPO3 link)
    - packages/phpunit-docs-theme/resources/template/structure/layoutParts/metaTags.html.twig
      (no TYPO3 meta tag)
    - packages/phpunit-docs-theme/resources/template/structure/layoutParts/pageHeader.html.twig
      (no TYPO3 menu)
    - packages/phpunit-docs-theme/resources/template/structure/navigation/navigationHeader.html.twig
      (no TYPO3 navigation)

## DEPENDENCIES

Current locks:

* phpdocumentor/guides and phpdocumentor/guides-cli are pinned due to
  breaking changes in flysystem / filesystem adapters
