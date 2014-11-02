require 'spec_helper'

describe Peredis::Resp::Serializer do

  let(:output) { StringIO.new() }
  subject { described_class.new(output) }

  describe "nil" do
    it "should serialize nil as a null bulk string" do
      subject.write(nil)
      expect(output.string).to eq("$-1\r\n")
    end
  end

  describe "integers" do
    it "should serialize the integer" do
      subject.write(12)
      expect(output.string).to eq(":12\r\n")
    end
  end

  describe "strings" do
    it "should serialize strings" do
      subject.write("foobar")
      expect(output.string).to eq("$6\r\nfoobar\r\n")
    end

    describe "empty string" do
      it "should serialize an empty string" do
        subject.write("")
        expect(output.string).to eq("$0\r\n\r\n")
      end
    end
  end

  describe "arrays" do
    it "should serialize arrays" do
      subject.write(["a", "b"])
      expect(output.string).to eq("*2\r\n$1\r\na\r\n$1\r\nb\r\n")
    end

    describe "empty arrays" do
      it "should serialize an empty array" do
        subject.write([])
        expect(output.string).to eq("*0\r\n")
      end
    end

    describe "with nil values" do
      it "should contain nil objects" do
        subject.write(['a', nil, 'b'])
        expect(output.string).to eq("*3\r\n$1\r\na\r\n$-1\r\n$1\r\nb\r\n")
      end

      describe "with only nil values" do
        it "should contain all nil objects" do
          subject.write([nil, nil])
          expect(output.string).to eq("*2\r\n$-1\r\n$-1\r\n")
        end
      end
    end

    describe "recursive arrays" do
      it "should support arrays of arrays" do
        subject.write(['a', ['b', 'c']])
        expect(output.string).to eq("*2\r\n$1\r\na\r\n*2\r\n$1\r\nb\r\n$1\r\nc\r\n")
      end
    end
  end

end
