# Optionally override some pagy default with your own in the pagy initializer
Pagy::DEFAULT[:limit] = 9 # items per page
Pagy::DEFAULT[:size] = 7 # nav bar links
# Better user experience handled automatically
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :last_page
# Require a CSS framework extra in the pagy initializer (e.g. bootstrap)
require 'pagy/extras/bootstrap'

require 'pagy/extras/array'
