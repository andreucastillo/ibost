#------------------------------------------------------------------------------------------
# Title: Functions associated with the database
# Project: Database Ostracoda Iberian Peninsula, Balearic Islands and Macaronesia
# Date: 28/08/2022
#------------------------------------------------------------------------------------------

# load database
load_database <- function(path = "database"){
  require(readxl)
  
  # locate data
  database_dir <- paste(getwd(), "/", path, sep   = "")
  files <- list.files(pattern = "*.xlsx", path = database_dir, full.names = TRUE)
  
  #load data in lists
  sample <- vector(mode = "list", length = length(files))
  names(sample) <- files
  taxonomy <- environment <- community <- sample
  for(i in 1:length(files)){
    sample[[i]] <- read_excel(files[i], sheet = "sample")
    community[[i]] <- read_excel(files[i], sheet = "community")
    environment[[i]] <- read_excel(files[i], sheet = "environment")
    taxonomy[[i]] <- read_excel(files[i], sheet = "taxonomy")
    taxonomy[[i]]$datasetID <- unique(sample[[i]]$datasetID)
    sample[[i]]$eventDate <- as.Date(sample[[i]]$eventDate)
    sample[[i]]$modified <- as.Date(sample[[i]]$modified)
  }
  data <- list("sample" = sample, "community" = community, "environment" = environment, "taxonomy" = taxonomy)
  return(data)
}

# Review species names
taxon_rev <- function(community, taxonomy){
  require(dplyr)
  require(tidyr)
  community_rev <- community
  for(i in 1:length(community_rev)){
    colnames(community_rev[[i]]) <- c("eventID", taxonomy[[i]]$speciesIDRev)
    community_rev[[i]] <- pivot_longer(community_rev[[i]], cols = colnames(community_rev[[i]])[-1])
    community_rev[[i]] <- community_rev[[i]] %>%
      group_by(eventID, name) %>%
      summarise_at(vars(value), sum, na.rm = TRUE)
    community_rev[[i]] <- pivot_wider(community_rev[[i]], names_from = name, values_from = value)
  }
  return(community_rev)
}   

# join datasets  (wide or long format)
join_dataset <- function(sample, community, environment, taxonomy, format = "wide", taxon_rev = TRUE){
  require(dplyr)
  require(tidyr)
  
  sample_full <- bind_rows(sample)
  
  if(format == "wide"){ # wide format
    if(taxon_rev == taxon_rev){
      community <- taxon_rev(community = community, taxonomy = taxonomy)
    }
    community_full <- bind_rows(community)
    n <- ncol(community_full)
    community_full <- community_full[,c(1,order(colnames(community_full[,2:n]))+1)]
    community_full[community_full == 0] <- NA
    environment_full <- bind_rows(environment)
    taxonomy_full <- bind_rows(taxonomy)
    data <- list("sample" = sample_full, "community" = community_full,
                 "environment" = environment_full, "taxonomy" = taxonomy_full)
  } else {
    if(format == "long"){ # long format (as darwin core)
      data <- community
      for(i in 1:length(data)){
        data[[i]] <- pivot_longer(community[[i]], cols = colnames(community[[i]])[-1])
        data[[i]] <- data[[i]][!is.na(data[[i]]$value),]
        colnames(data[[i]])[2] <- "speciesID"
        data[[i]] <- right_join(data[[i]], taxonomy[[i]][,1:13], by = "speciesID")
      }
      data <- bind_rows(data)
      data <- tibble(occurrenceID = paste("IMOST", data$eventID, data$speciesID, sep = "_"), data)
      data <- right_join(data, sample_full, by = "eventID")
      data$individualCount <- data$value
      data <- data[,-c(3:5)]
    } else {
      stop("Unused format. Format should be wide or long")
    }
  }
  return(data)
}

# function of functions
get_database <- function(path = "database", format = "wide", taxon_rev = TRUE, xlsx = TRUE, RData = TRUE){
  require(writexl)
  data_list <- load_database(path = path)
  data <- join_dataset(sample = data_list$sample, community = data_list$community, environment = data_list$environment,
                      taxonomy = data_list$taxonomy, format = format, taxon_rev = TRUE)
  
  # save database
  if(xlsx == TRUE){
    write_xlsx(data, path = paste("IMOST", format, ".xlsx", sep = ""))
  }
  if(RData == TRUE){
    save(data, file = paste("IMOST", format, ".RData", sep = "")) 
  }
  return(data)
}