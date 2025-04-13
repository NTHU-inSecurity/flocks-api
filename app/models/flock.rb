# frozen_string_literal: true

require 'json'
require 'sequel'

module Flocks
  # Models a flock (group) with destination
  class Flock < Sequel::Model
    one_to_many :birds
    plugin :association_dependencies, birds: :destroy
    plugin :timestamps

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
    
    def flock_id
      id
    end
    
    def find_by_username(find_name)
      bird = birds_dataset.first(username: find_name)
      return {} unless bird
      
      bird.to_h
    end
    
    def update_bird(find_name, new_data)
      bird = birds_dataset.first(username: find_name)
      return unless bird
      
      bird.update(message: new_data['message']) if new_data['message']
    end
    
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