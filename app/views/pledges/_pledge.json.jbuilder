json.extract! pledge, :id, :user_id, :project_id, :hours, :notes, :created_at, :updated_at
json.url pledge_url(pledge, format: :json)