require 'spec_helper'

describe Peredis::Resp::Parser do

  let(:data) { "" }
  let(:input) { StringIO.new(data) }
  subject { described_class.new(input) }

  describe "simple strings" do
    let(:data) { "+foobar\r\n" }

    it "should return the string object" do
      expect(subject.next).to eq("foobar")
    end

    describe "empty string" do
      let(:data) { "+\r\n" }

      it "should return an empty string" do
        expect(subject.next).to eq("")
      end
    end
  end

  describe "multiple objects" do
    describe "multiple strings" do
      let(:data) { "+abc\r\n+def\r\n" }

      it "should return each string, in order" do
        expect(subject.next).to eq("abc")
        expect(subject.next).to eq("def")
      end
    end
  end

end
