module ApplicationHelper
  include Pagy::Frontend

  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end

end
