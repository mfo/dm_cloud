require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'dm_cloud'

describe DmCloud::File do
  before(:each) do
    DmCloud.configure({:user_key => TEST_USER_KEY, :secret_key => TEST_SECRET_KEY, auto_call: false})
  end

  describe 'upload' do
    let(:call_type) { 'file.upload' }
    it 'should get an url' do
      result = DmCloud::File.upload
      result[:call].should == call_type
      result[:params].should == {call: call_type, args: {}}
    end
  end

  describe 'send_file' do
    let(:url) { 'http://upload-01.dmcloud.net/upload?uuid=foo&seal=bar' }
    let(:fd) { File.open(File.expand_path(File.dirname(__FILE__) + '../../../cloudkey-fixtures/video.3gp'), 'rb') }

    it 'should send file' do
      up = stub(foo: :bar)
      req = stub(foo: :bar)

      UploadIO.stubs(:new).with(fd, 'video/mp4', 'video.3gp').returns(up).once
      Net::HTTP::Post::Multipart.stubs(:new).with('/upload?uuid=foo&seal=bar', "file" => up).returns(req).once

      Net::HTTP.any_instance.stubs(:request).with(req).once

      DmCloud::File.send_file(url, fd)
    end
  end

end