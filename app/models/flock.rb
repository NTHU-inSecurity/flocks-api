# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a flock (group) with destination
  class Flock < Sequel::Model
    one_to_many :birds
    plugin :association_dependencies, birds: :destroy
    plugin :timestamps, update_on_create: true

    unrestrict_primary_key

    def birds=(bird_data_array)
      return unless bird_data_array

      save if new?
      bird_data_array.each do |bird_data|
        add_bird(bird_data)
      end
    end
    
    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'flock',
            attributes: {
              id:id ,
              destination_url:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
    
    # 為了向後兼容，提供 flock_id 方法
    def flock_id
      id
    end
    
    # 查找特定用戶名的鳥
    def find_by_username(find_name)
      bird = birds_dataset.first(username: find_name)
      return {} unless bird
      
      bird.to_h
    end
    
    # 更新鳥的信息
    def update_bird(find_name, new_data)
      bird = birds_dataset.first(username: find_name)
      return unless bird
      
      bird.update(message: new_data['message']) if new_data['message']
    end
    
    # 添加新的鳥
    def add_bird(bird_data)
      birds_dataset.insert(
        username: bird_data['username'],
        message: bird_data['message'],
        latitude: bird_data['latitude'],
        longitude: bird_data['longitude'],
        estimated_time: bird_data['estimated_time'],
        flock_id: id
      )
    end
  end
end