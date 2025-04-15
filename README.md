# Flocks API

Flocks API is a web application designed to store and share locations between friends. Users can create groups (flocks) with whom they want to share location information. Users can also choose to share their own location on maps.

## Overview

This application allows user to:

- Create location-sharing groups
- Pin meeting places on maps
- Share their current location with group members
- Track other users' locations to estimate arrival times
- Securely manage user accounts and location info.

Foe example, when friends decide to meet at a restaurant, one user can pin the location on the map, allowing everyone in the group tp see it.Group members can also share their real-time locations, making it easy to see if someone is running late.

## Requirements

- Ruby (>=3.0.0)
- Bundler (>=2.0.0)

### Dependencies

#### Web API

- base64 (~>0.1.0)
- json (~>2.6.0)
- logger (~>1.0)
- puma (~>6.0)
- roda (~>3.0)

#### Security

- rbnacl (~>7.0)

#### Testing

- minitest (~>5.0)
- minitest-rg (~>5.0)
- rack-test (~>5.0)
- rspec (~>3.12)

## Usage

### Running Test

Setup test database for once

- RACK_ENV=test rake db:migrate

Run the test specification script in Rakefile:

- rake spec

### Test type

- api_spec.rb: Testing api function and message.
- env_spec.rb: Testing for environment setting.
- flock_spec.rb: Testing the functionality of the Flock model.
- bird_spec.rb: Testing the functionality of the Bird model.
- spec_helper.rb: Provides common configuration for testing.
- test_load_all.rb: Setting the foundation for the test environment.

## API Endpoints

### ROOT

- `GET /` - Check if API is running

### Flocks

- `GET /api/v1/flocks` - Get a list of all flocks
- `GET /api/v1/flocks/:id` - Get details of a specific flock
- `POST /api/v1/flocks ` - Create a new flock
- `GET /api/v1/flocks/:id/:username` - Get a specific user's information within a flock
- `POST /api/v1/flocks/:id/:username` - Update a user's message within a flock

### Request/Response Format

All API endpoints accept and return JSON data.

#### Example: Creating a new Flock

Request:
POST /api/v1/flocks
Content-Type: application/json

    {
    "destination_url": "https://maps.app.goo.gl/example-location",
    "birds": [
        {
        "username": "user1",
        "message": "I'll be there soon",
        "latitude": 24.787404,
        "longitude": 120.988308,
        "estimated_time": 1200
        }
    ]
    }

Response:
HTTP/1.1 201 Created
Content-Type: application/json

    {
    "Message": "Flock data saved",
    "id": "abc123def45"
    }

## Models

### Flock

Represents a group with a shared destination.

- `flock_id`: Unique identifer
- `destination_url`:Google Maps URL for the meeting location
- `birds`: Array of Bird objects

### Bird

Represents a user within a flock

- `username`: User's name
- `message`: User's status message
- `latitude`: User's current latitude
- `longitude`: User's current longitude
- `estimated_time`: Estimated time to arrival in seconds
