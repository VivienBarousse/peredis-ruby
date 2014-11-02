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

  describe "bulk strings" do
    let(:data) { "$6\r\nfoobar\r\n" }
    
    it "should return the string object" do
      expect(subject.next).to eq("foobar")
    end

    it "should consume the whole buffer" do
      subject.next
      expect(input.read).to eq("")
    end

    context "when the string contains a CRLF character" do
      let(:data) { "$8\r\nfoo\r\nbar\r\n" }

      it "should return the string with the CRLF character" do
        expect(subject.next).to eq("foo\r\nbar")
      end

      context "when the string contains a CRLF character at the end" do
        let(:data) { "$8\r\nfoobar\r\n\r\n" }

        it "should return the string with the CRLF character" do
          expect(subject.next).to eq("foobar\r\n")
        end
      end
    end

    describe "empty bulk string" do
      let(:data) { "$0\r\n\r\n" }

      it "should return the empty string" do
        expect(subject.next).to eq("")
      end
    end

    describe "null bulk string" do
      let(:data) { "$-1\r\n" }

      it "should return nil" do
        expect(subject.next).to eq(nil)
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

    describe "multiple bulk strings" do
      let(:data) { "$3\r\nfoo\r\n$3\r\nbar\r\n" }

      it "should return each string, in order" do
        expect(subject.next).to eq("foo")
        expect(subject.next).to eq("bar")
      end
    end
  end

end
