#!/usr/bin/env bash

echo "Titre de votre article ?"
read titre

if [[ "$OSTYPE" == "darwin"* ]]; then
    slug=$(echo $titre | sed 'y/áàâäçéèêëîïìôöóùúüñÂÀÄÇÉÈÊËÎÏÔÖÙÜÑ/aaaaceeeeiiiooouuunAAACEEEEIIOOUUN/' | \
                  sed -E s/[^a-zA-Z0-9]+/-/g | \
                  sed -E s/^-+\|-+$//g | \
                  tr A-Z a-z)
else
    slug=$(echo $titre | sed 'y/áàâäçéèêëîïìôöóùúüñÂÀÄÇÉÈÊËÎÏÔÖÙÜÑ/aaaaceeeeiiiooouuunAAACEEEEIIOOUUN/' | \
                  sed -r s/[^a-zA-Z0-9]+/-/g | \
                  sed -r s/^-+\|-+$//g | \
                  tr A-Z a-z)
fi

hugo new "post/$slug.md"
sed -i '' "/title =/ s/= .*/= $titre/" "content/post/$slug.md"
