# How to make a release.
# * Configure new version number in invoicing/lib/invoicing/version.rb
# * Add details on the new release to History.txt

export VERSION=x.y.z

# Test locally:
(cd invoicing; rake manifest; rake install_gem)
(cd invoicing_generator; rake manifest; rake install_gem)
git commit -a -m "Set version number to $VERSION"

# `rake release` expects VERSION=... environment variable to be set
(cd invoicing; rake release)
(cd invoicing_generator; rake release)
(cd invoicing; rake post_news)

# Tag and push it
git tag -a -m "Tagging release $VERSION" "v$VERSION"
git push github
git push rubyforge
git push --tags github
git push --tags rubyforge
