import couchdb
import mariadb
import datetime

# Connect to CouchDB
couch = couchdb.Server("http://admin:couchdb@127.0.0.1:5984")
db_name = "music_comp"  # Replace with your desired database name

try:
    db = couch[db_name]
except couchdb.http.ResourceNotFound:
    db = couch.create(db_name)

    

# Connect to your Mariadb relational database
db_config = {
    "host": "127.0.0.1",
    "user": "root",
    "password": "mariadb",
    "database": "MusicCompDB"# Replace with the name of your database
}
conn = mariadb.connect(**db_config)
cursor = conn.cursor()
cursor.execute("USE MusicCompDB")

#Retrieve the data
fact_query = "SELECT vote_date_sk, viewer_sk, participant_sk, edition_sk, category_sk, COST FROM voteFacts"
cursor.execute(fact_query)
fact_data = cursor.fetchall()

# Creating a single document for each fact merging dimension data into each fact document
for row in fact_data:
    vdsk=int(row[0])
    vsk=int(row[1])
    psk=int(row[2])
    esk=int(row[3])
    csk=int(row[4])
    cost_str = str(row[5])
    
    if cost_str != 'None':
        cost = float(cost_str)
    else:
        cost = 0.0
    # Retrieve the student details
    cursor.execute("SELECT age_group_desc FROM dimViewer WHERE viewer_sk = %s", (vdsk,))
    age_group = cursor.fetchone()
    viewer_age_group=age_group[0]
    
    cursor.execute("SELECT county_name FROM dimViewer WHERE viewer_sk = %s", (vdsk,))
    viewer_county_data = cursor.fetchone()
    viewer_county = viewer_county_data[0]

    # Retreive the degree details
    cursor.execute("SELECT part_name FROM dimParticipant WHERE participant_sk = %s", (psk,))
    part_name = cursor.fetchone()
    participant_name = part_name[0]
    
    # Retrieve the course details
    cursor.execute("SELECT county_name FROM dimParticipant WHERE participant_sk = %s", (psk,))
    part_county = cursor.fetchone()
    participant_county = part_county[0]
    
    # Retrieve the course details
    cursor.execute("SELECT ed_year FROM dimEdition WHERE edition_sk = %s", (esk,))
    ed_year = cursor.fetchone()
    edition_year = ed_year[0]
    
    # Retrieve the course details
    cursor.execute("SELECT ed_presenter FROM dimEdition WHERE edition_sk = %s", (esk,))
    ed_presenter = cursor.fetchone()
    edition_presenter = ed_presenter[0]
    
    cursor.execute("SELECT cat_name FROM dimViewerCategory WHERE category_sk = %s", (csk,))
    category_name = cursor.fetchone()
    viewer_category = category_name[0]
    
    cursor.execute("SELECT vote_mode FROM dimVoteDate WHERE vote_date_sk = %s", (vdsk,))
    vote_mode = cursor.fetchone()
    voting_mode = vote_mode[0]
    
    cursor.execute("SELECT vote_date FROM dimVoteDate WHERE vote_date_sk = %s", (vdsk,))
    vote_date = cursor.fetchone()
    voting_date = vote_date[0].strftime('%Y/%m/%d')
    
    cursor.execute("SELECT vote FROM dimVoteDate WHERE vote_date_sk = %s", (vdsk,))
    vote_amt = cursor.fetchone()
    vote_amount = vote_amt[0]
    
    
    # Retrieve the date details
    # cursor.execute("SELECT examdate FROM DimDate WHERE date_sk = %s", (tsk,))
    # edate = cursor.fetchone()
    # ndate= edate[0].strftime("%m/%d/%Y")


    # Create a document for each fact 
    document = {
        "vote_date_sk": row[0],
        "voting_mode": voting_mode,
        "vote_date": voting_date,
        "vote_amount": vote_amount,
        "viewer_sk": row[1],
        "viewer_age_group": viewer_age_group,
        "viewer_county": viewer_county,
        "participant_sk": row[2],
        "participant_name": participant_name,
        "participant_county": participant_county,
        "edition_sk": row[3],
        "edition_year": edition_year,
        "edition_presenter": edition_presenter,
        "category_sk": row[4],
        "viewer_category": viewer_category,
        "vote_cost": cost,
    }

    # Insert the document into CouchDB
    
 
    db.save(document)

# Close database connections
cursor.close()
conn.close()
