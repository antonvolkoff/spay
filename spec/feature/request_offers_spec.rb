require 'spec_helper'

feature "Request Offers" do
  describe 'offers request form' do
    before(:each) { visit '/' }

    it 'should have necessary fields' do
      page.should have_css('input#offer_uid')
      page.should have_css('input#offer_pub0')
      page.should have_css('input#offer_page')
    end

    it 'should have optional fields' do
      within('.optional-fields') do
        page.should have_css('input#offer_appid')
        page.should have_css('input#offer_device_id')
        page.should have_css('input#offer_locale')
        page.should have_css('input#offer_ip')
        page.should have_css('input#offer_offer_types')
      end
    end
  end

  describe 'display offers' do
    it 'should show a no offers message when there is no offers' do
      stub_request(:get, /.*api.sponsorpay.com*./).
         with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => File.new("#{File.expand_path(__FILE__+'/../..')}/fixtures/no_offers.txt"), :headers => {})

      visit '/'
      fill_in 'offer_uid', with: 'player1'
      fill_in 'offer_pub0', with: 'campain1'
      fill_in 'offer_page', with: '1'
      click_button 'Send Request'

      page.should have_content('No offers')
    end

    it 'should show the list of offers' do
      stub_request(:get, /.*api.sponsorpay.com*./).
         with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
         to_return(
          :status => 200,
          :body => File.new("#{File.expand_path(__FILE__+'/../..')}/fixtures/offers.txt"),
          :headers => {'X-Sponsorpay-Response-Signature' => 'afb304db0ff6a8bac85147e450c49460c8cf26be'}
          )

      visit '/'
      fill_in 'offer_uid', with: 'player1'
      fill_in 'offer_pub0', with: 'campain1'
      fill_in 'offer_page', with: '1'
      click_button 'Send Request'

      page.should have_css('.title')
      page.should have_css('.payout')
      page.should have_css('.thumbnail')
    end
  end
end
