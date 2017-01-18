#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(migest)
library(circlize)

# Function for loading a single recptors smokeHour file
# Specifically pulls the "smokeHourSummary" part of the list
getRegionSources <- function(SHS, regionName){
  
  # We do not care about land cover right now, so sum the rows for each column
  totalSmokeHours <- apply(SHS, 2, sum)
  
  # Keep track of the source regions. TODO: Make sure that is the organization
  source_region <- colnames(SHS)
  
  # The SHS is the receptor for all of these values
  receptor_region <- rep(regionName, length(source_region))
  
  # Create summary df for the information about this region 
  df_single <- data.frame(source_region=source_region, 
                          receptor_region=receptor_region, 
                          totalSmokeHours=totalSmokeHours,
                          row.names = NULL)
  
  return(df_single)
  
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$smokeTransport <- renderPlot({
    
    # Arguments to set the type of data we are using
    metData     <- input$metData  
    years       <- input$years 
    usedRegions <- input$usedRegions
    
    # These are the only month options that work for the data in this analysis
    startMonth <- 6
    endMonth   <- 9
    method     <- "2day+6day_daily"
    plume      <- TRUE
    
    # Load regionNames and nice names, subset by chosen regions
    load("allRegionNames.RData")
    
    # Have to load single year files only. So loop over the range of years. 
    # Create a summary dataframe to store all of the information
    summary_df <- data.frame(source_region=character(0), 
                             receptor_region=character(0), 
                             totalSmokeHours=numeric(0))
    
    for (regionName in allRegionsNames){

      # Loop through each receptor region and open the required file. Need to 
      # make sure we have a fresh place to store this regions yearly information
      for(year in years){

        #print(paste("I am in the for loop", regionName))
        #print(class(regionName))
        
        # Create the filename based on arguments
        fileName <- paste0("smokeHourDataframes/",
                           regionName, "_",
                           "smokeHourSummary_", 
                           year,"-", year, "_",  # NOTE SINGLE YEAR HERE
                           "season=", startMonth,"-",endMonth, "_",
                           metData,"_",
                           method,"_",
                           "plume=",plume,".RData")
        
        # Loads "dataList" list object. These are in "smokeHourDataframes/"
        load(fileName)
        SHS <- dataList[["smokeHourSummary"]]
        
        # When this is a given regions first go, create regions_SHS
        if(year == years[1]){
          regions_SHS <- SHS
          regions_SHS[,] <- 0  # Set all values to zero 
        }
        
        # Add this years data to the ongoing total
        regions_SHS <- regions_SHS + SHS
        
        # convert from matrix to format required for plot
        if(year == years[length(years)]){        
          df_single_year <- getRegionSources(regions_SHS, regionName)
        }
        
      } # end of looping through one receptors years of data. 
      summary_df <- rbind(summary_df, df_single_year)
      
    } # end of region loop    
      
    # TODO: All subsetting by region should happen at this level. This means
    # TODO: getting rid of any row that does not contain a region that is in the
    # TODO: user passed array of selected regions. 
    
    sourceMask   <- summary_df$source_region   %in% usedRegions
    receptorMask <- summary_df$receptor_region %in% usedRegions
    rowMask      <- sourceMask & receptorMask
    
    # Subset the dataframe that contains all information. 
    summary_df <- summary_df[rowMask, ]
    
    
    # Now sort this data by source_region, do it alphabetically 
    sourceRegionAlphabetical <- order(summary_df$source_region)
    smoke_migration          <- summary_df[sourceRegionAlphabetical, ]
    
    region <- as.character(unique(smoke_migration$source_region))
    order_ <- order(region)
    
    # Figure out these regions and colors 
    load("regionLabelInfo.RData")
    regionColors     <- regionLabelInfo[["colors"]]
    regionLabelNames <- regionLabelInfo[["group"]]
    
    infoNeededIndex <- match(region, regionLabelNames)
    
    # Check it. This command messed up your career! 
    if( any(!(regionLabelNames[infoNeededIndex] == region)) ) {
      stop("ERROR: Cannot assign the correct colors to the chosen regions. Sorry")
    }
    
    col   <- regionColors[infoNeededIndex]

    
    if(input$border=="yes"){
      
      chordDiagram(smoke_migration, 
                   grid.col=col,
                   transparency=0.05,
                   directional = 1,
                   direction.type = c("arrows", "diffHeight"),
                   link.arr.type = "big.arrow",#"curved",
                   link.arr.length=0.06,
                   annotationTrack = c("name", "grid", "axis"), # "name", "grid", "axis"
                   link.sort = TRUE,
                   diffHeight = .1,
                   link.border=adjustcolor('black', alpha.f = 0.4)) # outlines the arrows that go between regions
      
    } else {
    
      # draw the histogram with the specified number of bins
      chordDiagram(smoke_migration, 
                   grid.col=col,
                   grid.border = NULL,
                   transparency=0.05,
                   directional = 1,
                   direction.type = c("arrows", "diffHeight"),
                   link.arr.type = "big.arrow",#"curved",
                   link.arr.length=0.06,
                   annotationTrack = c("grid"), # "name", "grid", "axis"
                   link.sort = TRUE,
                   diffHeight = .1,
                   link.border=adjustcolor('black', alpha.f = 0.4))
    }
      
  })
  
  
})

