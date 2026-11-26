require "helper"
require "tmpdir"
require "pdf/simpletable"

# Renders what the applications render, so a warning from any of it, a string literal changed in
# place among them, fails the test.
describe "Rendering" do
  ROOT = File.expand_path("..", File.dirname(__FILE__))

  it "renders text with tags, images, strokes and a table" do
    pdf = PDF::Writer.new
    pdf.select_font "Helvetica"
    pdf.text "Plain, <b>bold</b>, <i>italic</i> and <b><i>both</i></b>.", font_size: 12
    pdf.add_text 100, 500, "Rotated", 14, 30
    pdf.add_text_wrap 50, 400, 200, "A line long enough to wrap across the given width. " * 3, 10
    pdf.text "Centered text long enough to wrap onto a second line of the page. " * 2, justification: :center
    pdf.image File.join(ROOT, "images", "chunkybacon.jpg"), resize: 0.5
    pdf.image File.join(ROOT, "images", "chunkybacon.png"), resize: 0.5
    pdf.stroke_style PDF::Writer::StrokeStyle.new(2, cap: :round, join: :bevel, dash: { pattern: [4, 2], phase: 1 })
    pdf.line(50, 100, 300, 100).stroke
    pdf.rectangle(60, 110, 50, 20).fill_stroke
    pdf.start_new_page
    PDF::SimpleTable.new do |table|
      table.column_order = %w(name city)
      table.data = [{ "name" => "Hilton", "city" => "Köln" }, { "name" => "Maritim", "city" => "Bonn" }]
      table.render_on(pdf)
    end

    _(pdf.render).must_match(/\A%PDF-1\.3/)
  end

  %w(chunkybacon code demo hello pac).each do |name|
    it "renders the #{name} demo" do
      Dir.mktmpdir do |dir|
        # The demos read their images from ../images and write their PDF beside them.
        File.symlink(File.join(ROOT, "images"), File.join(dir, "images"))
        Dir.mkdir(File.join(dir, "demo"))
        Dir.chdir(File.join(dir, "demo")) { load File.join(ROOT, "demo", "#{name}.rb") }

        _(File.read(File.join(dir, "demo", "#{name}.pdf"), 8)).must_equal "%PDF-1.3"
      end
    end
  end
end
