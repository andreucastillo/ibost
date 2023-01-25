#------------------------------------------------------------------------------------------
# Title: Manage database
# Project: Database Ostracoda Iberian Peninsula, Balearic Islands and Macaronesia
# Date: 28/08/2022
#------------------------------------------------------------------------------------------

# download folder "database" from google drive
# unzip the folder (if it is necessary)
# the name of the folder should be "database"
# set the working directory where database was placed

# update function
source("imost_function.R")

# get database (firstly, unzip database folder. Folder name = database)
wide <- get_database(path = "database", format = "wide", taxon_rev = TRUE, xlsx = TRUE, RData = TRUE)
long <- get_database(path = "database", format = "long", taxon_rev = TRUE, xlsx = TRUE, RData = TRUE)

#--------------------------------------------------------------------------------------------
# Check data (long)

# occurrenceID
length(unique(long$occurrenceID)) == nrow(long) # it should be true. Avoid repeated occurrenceIDs

# collectioCodeID
length(unique(long$collectionCode)) # number of sources

# eventID
length(unique(long$eventID)) == nrow(wide$sample) # the same in the wide format
length(unique(long$eventID)) == nrow(wide$community) # the same in the wide format
length(unique(long$eventID)) == nrow(wide$environment) # the same in the wide format

# taxonomy
unique(long$kingdom) # only Animalia
unique(long$phylum) # only Arthropoda
unique(long$class) # only Ostracoda
unique(long$order) # only Podocopida
sort(unique(long$family)) # check them
sort(unique(long$genus)) # check them
sort(unique(long$specificEpithet)) # check them
sort(unique(long$infraspecificEpithet)) # check them

sort(unique(long$scientificName)) # check them
sort(unique(long$verbatimIdentification)) # check them

sort(unique(long$taxonRank)) # check them

# sources
sort(unique(long$datasetID)) # the same number of longsets
sort(unique(long$basisOfRecord)) # check them

# dates
sort(unique(as.Date(long$modified, "%Y-%m-%d"))) # check them
summary(unique(as.Date(long$eventDate, "%Y-%m-%d"))) # check them

summary(unique(long$decimalLatitude)) # check limits
summary(unique(long$decimalLongitude)) # check limits
unique(long$geodeticDatum) # WGS84
unique(long$georeferenceVerificationStatus) # check them

unique(long$habitat) # Check them
unique(long$countryCode) # ES, PT or AD
unique(long$node) # Yes or No

unique(long$bibliographicCitation)

unique(long$organismQuantityType) # check them
summary(unique(long$individualCount)) # check them

