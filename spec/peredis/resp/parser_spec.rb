require 'spec_helper'

describe Peredis::Resp::Parser do

  let(:data) { "" }
  let(:input) { StringIO.new(data) }
  subject { described_class.new(input) }

  describe "integers" do
    let(:data) { ":12\r\n" }

    it "should return the integer" do
      expect(subject.next).to eq(12)
    end

    it "should consume the whole buffer" do
      subject.next
      expect(input.read).to eq("")
    end

    describe "negative integers" do
      let(:data) { ":-12\r\n" }

      it "should return the negative integer" do
        expect(subject.next).to eq(-12)
      end
    end

    describe "large integers" do
      let(:data) { ":1234567890123456789012345678901234567890\r\n" }

      it "should return the long integer, without an overflow" do
        expect(subject.next).to eq(1234567890123456789012345678901234567890)
      end
    end

    describe "zero" do
      let(:data) { ":0\r\n" }

      it "should return zero" do
        expect(subject.next).to eq(0)
      end
    end
  end

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

  describe "inline commands" do

    let(:data) { "set foo bar" }

    it "should parse it correctly" do
      expect(subject.next).to eq(["set", "foo", "bar"])
    end

    context "single words" do
      let(:data) { "ping" }

      it "should parse it correctly" do
        expect(subject.next).to eq(["ping"])
      end
    end

  end

  describe "arrays" do
    let(:data) { "*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n" }

    it "should return the array" do
      expect(subject.next).to eq(["foo", "bar"])
    end

    describe "empty array" do
      let(:data) { "*0\r\n" }

      it "should return the empty array" do
        expect(subject.next).to eq([])
      end
    end

    describe "null array" do
      let(:data) { "*-1\r\n" }

      it "should return nil" do
        expect(subject.next).to eq(nil)
      end
    end

    describe "multiple data types" do
      let(:data) { "*4\r\n+foo\r\n$3\r\nbar\r\n$-1\r\n:123\r\n" }

      it "should return the correct array" do
        expect(subject.next).to eq(["foo", "bar", nil, 123])
      end
    end

    describe "recursive arrays" do
      let(:data) { "*2\r\n+a\r\n*2\r\n+b\r\n+c" }

      it "should return an array of arrays" do
        expect(subject.next).to eq(['a', ['b', 'c']])
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

    describe "multiple integers" do
      let(:data) { ":1\r\n:2\r\n:3\r\n" }

      it "should return each integer, in order" do
        expect(subject.next).to eq(1)
        expect(subject.next).to eq(2)
        expect(subject.next).to eq(3)
      end
    end
  end

end
