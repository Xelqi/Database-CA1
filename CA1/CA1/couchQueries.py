import couchdb

# Connect to CouchDB
couch = couchdb.Server("http://admin:couchdb@127.0.0.1:5984")
db_name = "music_comp"  # Replace with your desired database name

db = couch[db_name]

# Query to return participants who voted using a TV 
desired_voting_mode = "TV"

participants_who_voted_on_tv = []
limit = 10

for doc_id in db:
    doc = db[doc_id]
    voting_mode = doc.get('voting_mode')
    
    if voting_mode == desired_voting_mode:
        participants_who_voted_on_tv.append(doc)
        if len(participants_who_voted_on_tv) >= limit:
            break

# Print the participants with voting mode "TV"
for participant in participants_who_voted_on_tv:
    print(f"Participant ID: {participant['participant_sk']}  \tParticipant Name: {participant.get('participant_name')}  \t Viewer County: {participant.get('viewer_county')}  \tVoting Mode: {participant.get('voting_mode')}")
    
# Mango Query to return veiwers between age 18-24 who voted thru facebook, shows their id and county
 
# {
#    "selector": {
#       "viewer_age_group": "18-24",
#       "voting_mode": "Facebook"
#    },
#    "fields": [
#       "viewer_sk",
#       "participant_county"
#    ]
# }