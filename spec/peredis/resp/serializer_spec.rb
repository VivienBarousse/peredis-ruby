require 'spec_helper'

describe Peredis::Resp::Serializer do

  let(:output) { StringIO.new() }
  subject { described_class.new(output) }

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

end
