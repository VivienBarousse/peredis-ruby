require 'spec_helper'

describe Peredis::Storage::Memory do

  subject do
    described_class.new(config)
  end

  context "with a default config" do

    let(:config) do
      Hash.new
    end

    describe "generic methods" do
      describe "#ping" do
        it "should return pong" do
          expect(subject.ping).to eq("pong")
        end
      end

      describe "#exists" do
        context "when the key exists" do
          it "should return true" do
            subject.set("key", "value")
            expect(subject.exists("key")).to be(1)
          end
        end

        context "when the key doesn't exist" do
          it "should return false" do
            expect(subject.exists("key")).to be(0)
          end
        end
      end

      describe "#del" do
        context "when the key exists" do
          it "should return the number of deleted keys" do
            subject.set("key", "value")
            expect(subject.del("key")).to be(1)
          end

          it "should delete the key" do
            subject.del("key")
            expect(subject.exists("key")).to be(0)
          end
        end

        context "when the key doesn't exist" do
          it "should return the numbers of deleted keys" do
            expect(subject.del("key")).to be(0)
          end

          it "should not create the key" do
            subject.del("key")
            expect(subject.exists("key")).to be(0)
          end
        end

        context "when there are other keys" do
          it "should not delete other keys" do
            subject.set("key", "value")
            subject.set("key1", "value1")
            subject.del("key")
            expect(subject.exists("key1")).to be(1)
          end
        end

        describe "with more than one key to delete" do
          it "should delete all the keys" do
            subject.set("key", "value")
            subject.set("key1", "value1")
            subject.del("key", "key1")
            expect(subject.exists("key")).to be(0)
            expect(subject.exists("key1")).to be(0)
          end

          it "should return the number of keys deleted" do
            subject.set("key", "value")
            subject.set("key1", "value1")
            expect(subject.del("key", "key1")).to eq(2)
          end

          context "when not all the keys exist" do
            it "should delete the existing keys" do
              subject.set("key", "value")
              subject.del("key", "key1")
              expect(subject.exists("key")).to be(0)
            end

            it "should not create the non-existing keys" do
              subject.set("key", "value")
              subject.del("key", "key1")
              expect(subject.exists("key1")).to be(0)
            end

            it "should return just the number of deleted keys" do
              subject.set("key", "value")
              expect(subject.del("key", "key1")).to eq(1)
            end
          end
        end
      end
    end

    describe "strings" do

      let(:key) { "string-key" }

      describe "#get" do
        it "should return the value" do
          subject.set(key, "value")
          expect(subject.get(key)).to eq("value")
        end

        context "the value doesn't exist" do
          it "should return nil" do
            expect(subject.get(key)).to be_nil
          end
        end

        context "the value is of the wrong type" do
          it "should raise an error" do
            subject.sadd(key, "value")
            expect {
              subject.get(key)
            }.to raise_error
          end
        end
      end

      describe "#set" do
        it "should set the value" do
          subject.set(key, "value")
          expect(subject.get(key)).to eq("value")
        end

        context "when the key already exists" do
          it "should override it" do
            subject.set(key, "value")
            subject.set(key, "value2")
            expect(subject.get(key)).to eq("value2")
          end

          context "and is a different type" do
            it "should override it" do
              subject.sadd(key, "value")
              subject.set(key, "value2")
              expect(subject.get(key)).to eq("value2")
            end
          end
        end

        describe "#mset" do
          let(:key1) { "string1" }
          let(:key2) { "string2" }

          it "should set the values" do
            subject.mset(key1, "value1", key2, "value2")
            expect(subject.get(key1)).to eq("value1")
            expect(subject.get(key2)).to eq("value2")
          end

          context "when the keys already exist" do
            it "should set the values" do
              subject.set(key1, "foo")
              subject.set(key2, "foo")
              subject.mset(key1, "value1", key2, "value2")
              expect(subject.get(key1)).to eq("value1")
              expect(subject.get(key2)).to eq("value2")
            end

            context "and are of a different type" do
              it "should set the values" do
                subject.sadd(key1, "foo")
                subject.sadd(key2, "foo")
                subject.mset(key1, "value1", key2, "value2")
                expect(subject.get(key1)).to eq("value1")
                expect(subject.get(key2)).to eq("value2")
              end
            end
          end
        end
      end
    end

    describe "integers" do

      let(:key) { "integer-key" }

      describe "#incr" do

        it "should increment the value by 1" do
          subject.set(key, "2")
          subject.incr(key)
          expect(subject.get(key)).to eq("3")
          subject.incr(key)
          expect(subject.get(key)).to eq("4")
        end

        it "should return the value it just set" do
          subject.set(key, "2")
          expect(subject.incr(key)).to eq(3)
          expect(subject.incr(key)).to eq(4)
        end

        context "when the number is negative" do
          it "should increment the value by 1" do
            subject.set(key, "-11")
            subject.incr(key)
            expect(subject.get(key)).to eq("-10")
            subject.incr(key)
            expect(subject.get(key)).to eq("-9")
          end

          it "should return the value it just set" do
            subject.set(key, "-11")
            expect(subject.incr(key)).to eq(-10)
            expect(subject.incr(key)).to eq(-9)
          end

          it "should be able to go in the positive numbers" do
            subject.set(key, "-1")
            expect(subject.incr(key)).to eq(0)
            expect(subject.incr(key)).to eq(1)
          end
        end

        context "when the key doesn't exist" do
          it "should set the value to 1" do
            subject.incr(key)
            expect(subject.get(key)).to eq("1")
          end
        end

        context "when the key isn't a valid integer" do
          it "should raise an error" do
            subject.set(key, "a")
            expect {
              subject.incr(key)
            }.to raise_error
          end
        end
      end

    end

    describe "sets" do

      let(:key) { "set-key" }

      describe "#sadd" do
        it "should add an element to the set" do
          subject.sadd(key, "value1")
          subject.sadd(key, "value2")
          subject.sadd(key, "value3")
          expect(subject.smembers(key)).to eq(Set.new(%w(value1 value2 value3)))
        end

        it "should not add duplicate values" do
          subject.sadd(key, "value1")
          subject.sadd(key, "value2")
          subject.sadd(key, "value1")
          expect(subject.smembers(key)).to eq(Set.new(%w(value1 value2)))
        end

        context "with more than one value to add" do
          it "should add all the values" do
            subject.sadd(key, "value1", "value2", "value3")
            expect(subject.smembers(key)).to eq(Set.new(%w(value1 value2 value3)))
          end

          it "should not add any duplicate values" do
            subject.sadd(key, "value1", "value2", "value1")
            expect(subject.smembers(key)).to eq(Set.new(%w(value1 value2)))
          end
        end

        context "when the key exists and is not a set" do
          it "should raise an error" do
            subject.set(key, "value")
            expect {
              subject.sadd(key, "value")
            }.to raise_error
          end
        end
      end

      describe "#smembers" do
        it "should retrieve all the elements from the set" do
          subject.sadd(key, "value1")
          subject.sadd(key, "value2")
          subject.sadd(key, "value3")
          expect(subject.smembers(key)).to eq(Set.new(%w(value1 value2 value3)))
        end

        context "when I try to modify the returned set" do
          it "should not change the status of the stored set" do
            subject.sadd(key, "value1")
            returned = subject.smembers(key)
            expect(returned).to eq(Set.new(%w(value1)))

            returned << "value2"
            expect(returned).to eq(Set.new(%w(value1 value2)))

            expect(subject.smembers(key)).to eq(Set.new(%w(value1)))
          end

        end

        context "when the key already exists and is not a set" do
          it "should raise an error" do
            subject.set(key, "value")
            expect {
              subject.smembers(key)
            }.to raise_error
          end

          it "should not override the value" do
            subject.set(key, "value")
            subject.smembers(key) rescue nil
            expect(subject.get(key)).to eq("value")
          end
        end

        context "when the key doesn't exist beforehand" do
          it "should return an empty set" do
            expect(subject.smembers(key)).to eq(Set.new())
          end

          it "should not create the key" do
            subject.smembers(key)
            expect(subject.exists(key)).to be(0)
          end
        end
      end

      describe "#sismember" do
        context "when the value is in the set" do
          it "should return true" do
            subject.sadd(key, "value")
            expect(subject.sismember(key, "value")).to be(true)
          end
        end

        context "when the value is not in the set" do
          it "should return false" do
            subject.sadd(key, "another_value")
            expect(subject.sismember(key, "value")).to be(false)
          end
        end

        context "when the key doesn't exist" do
          it "should return false" do
            subject.sismember(key, "value")
          end

          it "should not create the key" do
            subject.sismember(key, "value")
            expect(subject.exists(key)).to be(0)
          end
        end

        context "when the key is of the wrong type" do
          it "should raise and error" do
            subject.set(key, "value")
            expect {
              subject.sismember(key, "value")
            }.to raise_error
          end
        end
      end

      describe "#scard" do
        it "should return the cardinality of the set" do
          subject.sadd(key, "value1", "value2", "value3")
          expect(subject.scard(key)).to eq(3)
        end

        context "when there are duplicates" do
          it "should not count duplicates" do
            subject.sadd(key, "value1", "value2", "value1")
            expect(subject.scard(key)).to eq(2)
          end
        end

        context "when the key doesn't exist" do
          it "should return 0" do
            expect(subject.scard(key)).to eq(0)
          end

          it "should not create it" do
            subject.scard(key)
            expect(subject.exists(key)).to be(0)
          end
        end

        context "when the key is of the wrong type" do
          it "should raise an errror" do
            subject.set(key, "value")
            expect {
              subject.scard(key)
            }.to raise_error
          end
        end
      end
    end
  end
end
