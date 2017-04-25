json.extract! check_in, :id, :user_id, :project_id, :muster_id, :location_lat, :location_lon, :location, :created_at, :updated_at
json.url check_in_url(check_in, format: :json)