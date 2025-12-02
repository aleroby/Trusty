module ApplicationHelper
  include Pagy::Frontend

  def render_markdown(text)
    Kramdown::Document.new(text, input: 'GFM', syntax_highlighter: "rouge").to_html
  end

  def avatar_bg_color_for(user)
    palette = %w(#e0f2fe #dbeafe #dcfce7 #fef9c3 #ffe4e6 #e0f2f1 #ede9fe)
    seed = user&.id || user&.email&.hash || user&.first_name&.hash || 0
    palette[seed.to_i.abs % palette.length]
  end

end
