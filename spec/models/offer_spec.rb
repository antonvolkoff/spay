require 'spec_helper'

describe Offer do
  describe '#request_uri' do
    let(:offer) { Offer.new({uid: 'payer1', pub0: 'campain1', page: '1'}) }

    it 'should return uri to request' do
      request_uri = offer.request_uri
      # splite on multiple lines
      request_uri.include?('http://api.sponsorpay.com/feed/v1/offers.json?').should be
      request_uri.include?("appid=157&device_id=2b6f0cc904d137be2%20e1730235f5664094b%20831186&ip=109.235.143.113&locale=de&offer_types=112&page=1&pub0=campain1&timestamp=#{Time.now.to_i}").should be
      request_uri.include?("&uid=payer1&hashkey=#{offer.send(:hash_params, offer.send(:generate_params))}")
    end

    it 'should not put validation_content into uri after validate' do
      offer.valid?
      offer.request_uri.include?('validation_content').should_not be
    end
  end

  describe '#make_request' do
    let(:offer) { Offer.new({uid: 'payer1', pub0: 'campain1', page: '1'}) }

    it 'should return hash' do
      WebMock.disable! # we will make a real requests
      offer.make_request.should be_kind_of(Hash)
    end
  end

  describe '#get' do
    let(:offer) { Offer.new({uid: 'payer1', pub0: 'campain1', page: '1'}) }

    it 'should return an array of offers' do
      WebMock.disable! # we will make a real requests
      offer.get.should be_kind_of(Array)
    end
  end
end