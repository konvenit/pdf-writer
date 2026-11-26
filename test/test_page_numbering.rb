require "helper"

describe "Page Numbering" do
  
  before :each do 
    @pdf = PDF::Writer.new
  end
  
  it "should start with a current page = 1" do
    _(@pdf.current_page_number).must_equal 1
  end   
  
end