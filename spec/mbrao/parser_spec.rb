# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun@cowtech.it>.
# Licensed under the MIT license, which can be found at https://choosealicense.com/licenses/mit.
#

require "spec_helper"

describe Mbrao::Parser do
  class BlankParser
    def parse(content, options)

    end
  end

  class ::Mbrao::ParsingEngines::ScopedParser
    def parse(content, options)

    end
  end

  it "should correctly setup datetime JSON serialization" do
    expect(ActiveSupport.use_standard_json_time_format).to be_truthy
  end

  shared_examples_for("attribute_with_default") do |attribute, default, sanitizer|
    it "should return the default value" do
      ::Mbrao::Parser.send("#{attribute}=", nil)
      expect(::Mbrao::Parser.send(attribute)).to eq(default)
    end

    it "should return the set value sanitized" do
      ::Mbrao::Parser.send("#{attribute}=", :en)
      expect(::Mbrao::Parser.send(attribute)).to eq("en".send(sanitizer))
    end
  end

  describe ".locale" do
    it_should_behave_like("attribute_with_default", :locale, "en", :ensure_string)
  end

  describe ".parsing_engine" do
    it_should_behave_like("attribute_with_default", :parsing_engine, :plain_text, :to_sym)
  end

  describe ".rendering_engine" do
    it_should_behave_like("attribute_with_default", :rendering_engine, :html_pipeline, :to_sym)
  end

  describe ".parse" do
    it "should forward to the instance" do
      expect(::Mbrao::Parser.instance).to receive(:parse).with("TEXT", {options: {}})
      ::Mbrao::Parser.parse("TEXT", {options: {}})
    end
  end

  describe ".render" do
    it "should forward to the instance" do
      expect(::Mbrao::Parser.instance).to receive(:render).with("TEXT", {options: {}}, {content: {}})
      ::Mbrao::Parser.render("TEXT", {options: {}}, {content: {}})
    end
  end

  describe ".create_engine" do
    it "should create an engine via Lazier.find_class" do
      subject = ::Mbrao::ParsingEngines::ScopedParser.new
      cls = ::Mbrao::ParsingEngines::ScopedParser
      expect(cls).to receive(:new).exactly(2).and_return(subject)

      expect(::Lazier).to receive(:find_class).with(:scoped_parser, "::Mbrao::ParsingEngines::%CLASS%").and_return(cls)
      expect(::Mbrao::Parser.create_engine(:scoped_parser)).to eq(subject)
      expect(::Lazier).to receive(:find_class).with(:scoped_parser, "::Mbrao::RenderingEngines::%CLASS%").and_return(cls)
      expect(::Mbrao::Parser.create_engine(:scoped_parser, :rendering)).to eq(subject)
    end

    it "should raise an exception if the engine class is not found" do
      expect { ::Mbrao::Parser.create_engine(:invalid) }.to raise_error(::Mbrao::Exceptions::UnknownEngine)
    end
  end

  describe ".instance" do
    it("should call .new") do
      ::Mbrao::Parser.instance_variable_set(:@instance, nil)
      expect(::Mbrao::Parser).to receive(:new)
      ::Mbrao::Parser.instance
    end

    it("should return the same instance") do
      allow(::Mbrao::Parser).to receive(:new) do Time.now end
      instance = ::Mbrao::Parser.instance
      expect(::Mbrao::Parser.instance).to be(instance)
      ::Mbrao::Parser.instance_variable_set(:@instance, nil)
    end

    it("should return a new instance if requested to") do
      allow(::Mbrao::Parser).to receive(:new) do Time.now end
      instance = ::Mbrao::Parser.instance
      expect(::Mbrao::Parser.instance(true)).not_to be(instance)
      ::Mbrao::Parser.instance_variable_set(:@instance, nil)
    end
  end

  describe ".email?" do
    it "should check for valid emails" do
      expect(Mbrao::Parser.email?("valid@email.com")).to be_truthy
      expect(Mbrao::Parser.email?("valid@localhost")).to be_falsey
      expect(Mbrao::Parser.email?("this.is.9@email.com")).to be_truthy
      expect(Mbrao::Parser.email?("INVALID")).to be_falsey
      expect(Mbrao::Parser.email?(nil)).to be_falsey
      expect(Mbrao::Parser.email?([])).to be_falsey
      expect(Mbrao::Parser.email?("this.is.9@email.com.uk")).to be_truthy
    end
  end

  describe ".url?" do
    it "should check for valid URLs" do
      expect(Mbrao::Parser.url?("http://google.it")).to be_truthy
      expect(Mbrao::Parser.url?("ftp://ftp.google.com")).to be_truthy
      expect(Mbrao::Parser.url?("http://google.it/?q=FOO+BAR")).to be_truthy
      expect(Mbrao::Parser.url?("INVALID")).to be_falsey
      expect(Mbrao::Parser.url?([])).to be_falsey
      expect(Mbrao::Parser.url?(nil)).to be_falsey
      expect(Mbrao::Parser.url?({})).to be_falsey
    end
  end

  describe "#parse" do
    it "should sanitize options" do
      subject = BlankParser.new
      expect(::Mbrao::Parser).to receive(:create_engine).exactly(3).and_return(subject)

      expect(subject).to receive(:parse).with("CONTENT", {"metadata" => true, "content" => true, "engine" => :blank_parser})
      expect(subject).to receive(:parse).with("CONTENT", {"metadata" => true, "content" => false, "engine" => :blank_parser})
      expect(subject).to receive(:parse).with("CONTENT", {"metadata" => false, "content" => false, "engine" => :blank_parser})

      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser})
      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser, content: 2})
      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser, metadata: false, content: false})
    end

    it "should call .create_engine call its #parse method" do
      subject = BlankParser.new
      expect(::Mbrao::Parser).to receive(:create_engine).and_return(subject)

      expect(subject).to receive(:parse).with("CONTENT", {"metadata" => true, "content" => true, "engine" => :blank_parser, "other" => "OK"})
      ::Mbrao::Parser.new.parse("CONTENT", {engine: :blank_parser, other: "OK"})
    end
  end

  describe "#render" do
    it "should sanitize options" do
      subject = Object.new
      expect(::Mbrao::Parser).to receive(:create_engine).exactly(2).and_return(subject)

      expect(subject).to receive(:render).with("CONTENT", {"engine" => :blank_rendered}, {content: "OK"})
      expect(subject).to receive(:render).with("CONTENT", {"engine" => :html_pipeline}, {content: "OK"})

      ::Mbrao::Parser.new.render("CONTENT", {engine: :blank_rendered}, {content: "OK"})
      ::Mbrao::Parser.new.render("CONTENT", {engine: :html_pipeline}, {content: "OK"})
    end

    it "should call .create_engine call its #parse method" do
      subject = Object.new
      expect(::Mbrao::Parser).to receive(:create_engine).with(:blank_rendered, :rendering).and_return(subject)

      expect(subject).to receive(:render).with("CONTENT", {"engine" => :blank_rendered}, {content: "OK"})
      ::Mbrao::Parser.new.render("CONTENT", {engine: :blank_rendered}, {content: "OK"})
    end
  end
end
