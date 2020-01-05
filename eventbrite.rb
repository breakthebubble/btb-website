require 'json'
require 'httparty'

if ARGV.length != 1
    puts "Wrong number of arguments"
    puts "Usage: 'ruby eventbrite.rb /path/to/output/json'"
    exit
end

#options = { query: { token: ENV["EVENTBRITE_PRIVATE_TOKEN"] } }
headers = { 'Authorization'=> "Bearer #{ENV["EVENTBRITE_PRIVATE_TOKEN"]}" }
p headers

h_user = HTTParty.get("https://www.eventbriteapi.com/v3/users/me/", :headers => headers ).parsed_response
p h_user
puts "User ID: " + h_user_id = h_user['id']

h_orgs = HTTParty.get("https://www.eventbriteapi.com/v3/users/me/organizations/", :headers => headers ).parsed_response
puts "Organization ID: " + h_org_id = h_orgs['organizations'][0]['id']


h_event_resp = HTTParty.get("https://www.eventbriteapi.com/v3/organizations/"+h_org_id+"/events/", :headers => headers ).parsed_response
h_events = h_event_resp['events']
while h_event_resp['pagination']['has_more_items']
    query = { continuation: h_event_resp['pagination']['continuation'] }
    h_event_resp = HTTParty.get("https://www.eventbriteapi.com/v3/organizations/"+h_org_id+"/events/", :query => query, :headers => headers ).parsed_response
    h_events = h_events + h_event_resp['events']
end

puts "Number of Events in Organization: " + h_events.length.to_s()
h_events.each do |n|
    if n['organization_id'] != h_org_id
        puts "Found event with different Organization"
        puts "organization_id = " + n['organization_id']
    end
    if n['organizer_id'] != "4178289715"
        puts "Found event within Organization with different Organizer"
        puts "organizer_id = " + n['organizer_id']
    end
end

File.open(ARGV[0],"w") do |f|
    f.write(h_events.to_json)
end
