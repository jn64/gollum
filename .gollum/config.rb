# <https://github.com/gollum/gollum/wiki/Sample-config.rb>

wiki_options = {
  # Default git branch
  ref: "main",

  index_page: "index",
  # Use first H1 in the file as page title
  h1_title: true,
  display_metadata: true,
  # Header numbering
  header_enum: false,
  universal_toc: false,
  # sidebar: :left,

  math: :katex,
  critic_markup: false,
  # Emoji markup like :heart:
  emoji: true,

  # Load custom CSS from ./custom.css
  # css: true,
  # Load custom JS from ./custom.js
  # js: true,

  # Filename handling
  # <https://github.com/gollum/gollum/wiki/5.0-release-notes#no-global-file-names>
  global_tag_lookup: false,
  case_insensitive_tag_lookup: true,
  hyphened_tag_lookup: true,

  # Show page history across renames.
  # May have performance impact on large histories.
  follow_renames: true,

  allow_editing: true,
  # Upload files to ./uploads/
  allow_uploads: true,

  show_local_time: true
}

Precious::App.set(:wiki_options, wiki_options)

Precious::App.set(:default_markup, :markdown)

GitHub::Markup::Markdown::MARKDOWN_GEMS["commonmarker"] = proc { |content, options: {}|
  CommonMarker.render_html(
    content,
    # commonmarker render options
    # <https://github.com/gjtorikian/commonmarker/tree/v0.23.11#render-options>
    [:VALIDATE_UTF8, :FOOTNOTES, :SMART],
    # commonmarker extensions (all enabled)
    # <https://github.com/gjtorikian/commonmarker/tree/v0.23.11#extensions>
    [:autolink, :strikethrough, :table, :tagfilter, :tasklist]
  )
}
