wiki_options = {
  mathjax: false,
  display_metadata: true,
  # Default git branch
  ref: "main",
  index_page: "index",
}

Precious::App.set(:wiki_options, wiki_options)
Precious::App.set(:default_markup, :markdown)

# Enable footnotes, smart punctuation (e.g. curly quotes), and all extensions
# as of commonmark 0.23.9.
# See <https://github.com/gjtorikian/commonmarker/blob/42cfc90251353f9fceda91b884d0ded8d3da0bcf/README.md#options>
GitHub::Markup::Markdown::MARKDOWN_GEMS["commonmarker"] = proc { |content, options: {}|
  CommonMarker.render_html(content, [:FOOTNOTES, :SMART], [:tagfilter, :autolink, :table, :strikethrough, :tasklist])
}
