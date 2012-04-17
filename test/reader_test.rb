# Allow examples to be run in-place without requiring a gem install
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'symmetric-encryption'

# Load Symmetric Encryption keys
SymmetricEncryption.load!(File.join(File.dirname(__FILE__), 'config', 'symmetric-encryption.yml'), 'test')

# Unit Test for SymmetricEncrypted::ReaderStream
#
class ReaderTest < Test::Unit::TestCase
  context 'Reader' do
    setup do
      @data = [
        "Hello World\n",
        "Keep this secret\n",
        "And keep going even further and further..."
      ]
      @data_str = @data.inject('') {|sum,str| sum << str}
      @data_len = @data_str.length
      @data_encrypted = SymmetricEncryption.cipher.encrypt(@data_str)
      @filename = '._test'
    end

    should "decrypt from string stream as a single read" do
      stream = StringIO.new(@data_encrypted)
      decrypted = SymmetricEncryption::Reader.open(stream) {|file| file.read}
      assert_equal @data_str, decrypted
    end

    should "decrypt from string stream as a single read, after a partial read" do
      stream = StringIO.new(@data_encrypted)
      decrypted = SymmetricEncryption::Reader.open(stream) do |file|
        file.read(10)
        file.read
      end
      assert_equal @data_str[10..-1], decrypted
    end

    should "decrypt lines from string stream" do
      stream = StringIO.new(@data_encrypted)
      i = 0
      decrypted = SymmetricEncryption::Reader.open(stream) do |file|
        file.each_line do |line|
          assert_equal @data[i], line
          i += 1
        end
      end
    end

    should "decrypt fixed lengths from string stream" do
      stream = StringIO.new(@data_encrypted)
      i = 0
      SymmetricEncryption::Reader.open(stream) do |file|
        index = 0
        [0,10,5,5000].each do |size|
          buf = file.read(size)
          if size == 0
            assert_equal '', buf
          else
            assert_equal @data_str[index..index+size-1], buf
          end
          index += size
        end
      end
    end

    should "decrypt from file" do

    end
  end

end