require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require 'ostruct'

describe "several exhibits" do
  let(:model) { stub }
  let(:first_exhibit) { new_exhibit }
  let(:second_exhibit) { new_exhibit }

  before do
    @exhibits = [first_exhibit, second_exhibit]
    stub(DisplayCase::Exhibit).exhibits { @exhibits }
    @exhibited = DisplayCase::Exhibit.exhibit(model)
  end

  it "exhibited should include defined exhibits" do
    @exhibited.exhibit_chain.must_include first_exhibit
    @exhibited.exhibit_chain.must_include second_exhibit
  end

  it "should correctly send #render messages to exhibits" do
    mock.instance_of(first_exhibit).render.with_any_args
    context = stub!

    @exhibited.render(context)
  end

  it "should apply Basic Exhibit by default" do
    @exhibited.exhibit_chain.must_include DisplayCase::BasicExhibit
  end

  describe "message delegation" do
    it "should delegate messages as inheritance, starting from first exhibit in chain" do
      first_exhibit.class_eval do
        def render
          pointer.title
        end
      end
      mock.instance_of(second_exhibit).title

      @exhibited.render
    end

    it "should not be influenced by other manual exhibitions" do
      skip "fix it to allow custom exhibitions"
      other_exhibit = new_exhibit
      mock.instance_of(other_exhibit).title
      object = other_exhibit.new(@exhibited, stub!)

      first_exhibit.class_eval do
        def render
          pointer.title
        end
      end

      @exhibited.render
    end

    it "should not be influenced by other calls to exhibit" do
      skip "fix it to allow multiple calls to .exhibit"
      # other exhibition
      @exhibits = [new_exhibit, new_exhibit]
      stub(DisplayCase::Exhibit).exhibits { @exhibits }
      DisplayCase::Exhibit.exhibit(stub(:junk))

      first_exhibit.class_eval do
        def render
          pointer.title
        end
      end
      mock.instance_of(second_exhibit).title

      @exhibited.render
    end
  end

  private
  def new_exhibit
    Class.new(DisplayCase::Exhibit) { def self.applicable_to?(*args); true; end }
  end
end
