# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Flocks Web API' do
  describe 'Root route' do
    it 'should find the root route' do
      get '/'
      _(last_response.status).must_equal 200
      response_body = JSON.parse(last_response.body)
      _(response_body['message']).must_equal 'FlocksAPI up at /api/v1'
    end
  end
  
  describe 'Flocks route' do
    before do
      wipe_database
    end

    it 'HAPPY: should be able to get list of all flocks' do
      # test data
      flock0 = Flocks::Flock.create(destination_url: DATA[:flocks][0]['destination_url'])
      DATA[:flocks][0]['birds'].each { |b| flock0.add_bird(b) }
      
      flock1 = Flocks::Flock.create(destination_url: DATA[:flocks][1]['destination_url'])
      DATA[:flocks][1]['birds'].each { |b| flock1.add_bird(b) }

      get 'api/v1/flocks'
      _(last_response.status).must_equal 200
      result = JSON.parse last_response.body
      _(result['flock_ids']).wont_be_nil
    end

    it 'HAPPY: should be able to get details of a single flock' do
      # 創建一個測試 flock
      flock_data = DATA[:flocks][1]
      flock = Flocks::Flock.create(destination_url: flock_data['destination_url'])
      
      # 為了測試目的，我們可以直接在數據庫中查詢這個 flock
      test_flock = Flocks::Flock.first(destination_url: flock_data['destination_url'])
      flock_id = test_flock.id
      
      get "/api/v1/flocks/#{flock_id}"
      _(last_response.status).must_equal 200
      
      result = JSON.parse last_response.body
      
      # 檢查返回數據的結構，並打印出來
      puts "Response JSON structure: #{result.inspect}"
      
      # 嘗試不同的路徑來訪問 destination_url
      if result.is_a?(Hash) && result['data']
        # 如果使用 JSON API 格式（嵌套在 data.attributes 下）
        _(result['data']['attributes']['destination_url']).must_equal flock_data['destination_url']
      elsif result.is_a?(Hash) && result['destination_url']
        # 如果直接在最上層
        _(result['destination_url']).must_equal flock_data['destination_url']
      elsif result.is_a?(Hash) && result['type'] == 'flock'
        # 另一種可能的格式
        _(result['destination_url']).must_equal flock_data['destination_url']
      else
        # 如果都找不到，則測試失敗
        flunk("Could not find destination_url in response: #{result.inspect}")
      end
    end

          it 'HAPPY: should be able to create new flocks' do
            flock_data = DATA[:flocks][0]
            req_header = { 'CONTENT_TYPE' => 'application/json' }
            post 'api/v1/flocks', flock_data.to_json, req_header
            
            _(last_response.status).must_equal 201
    end

    it 'SAD: should return error if unknown flock requested' do
      get '/api/v1/flocks/foobar'
      _(last_response.status).must_equal 404
    end
  end
end