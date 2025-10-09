# config/initializers/default_meta.rb
# Inicializa las metaetiquetas predeterminadas cargando meta.yml
DEFAULT_META = YAML.load_file(Rails.root.join("config/meta.yml"))
