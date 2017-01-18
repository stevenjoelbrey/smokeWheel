#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for slider demo application
shinyUI(pageWithSidebar(
  
  #  Application title
  headerPanel("Smoke Source Climatology Wheel"),
  
  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(
    
    
    radioButtons("metData", "Meteorology Data:", c("gdas1", "edas40"), 
                 selected = "gdas1", inline = TRUE),
    
    radioButtons("border", "Show Border:", c("yes", "no"), 
                 selected = "yes", inline = TRUE),
    
    checkboxGroupInput("usedRegions", "Regions to include:",
                       c("Northeast" = "NorthEast",                 
                         "Mid Atlantic" = "MidAtlantic",              
                         "Southeast" =  "SouthEast",              
                         "Midwest"=  "MidWest",
                         "Southern Plains"=  "SouthernPlains",
                         "Great Plains"=  "GreatPlains",
                         "Rocky Mountains" =  "RockyMountains", 
                         "Southwest" = "SouthWest" ,
                         "Northwest"     =  "NorthWest",    
                         "Alaska"           =  "Alaska",
                         "Mexico" =  "Mexico",                  
                         "Quebec"  =  "Quebec",     
                         "Nova Scotia" = "Nova Scotia" ,   
                         "Saskatchewan"  =  "Saskatchewan",           
                         "Alberta" = "Alberta" ,    
                         "Newfoundland and Labrador" =  "Newfoundland and Labrador",
                         "British Columbia"  =  "British Columbia",       
                         "New Brunswick" =  "New Brunswick",    
                         "Prince Edward Island"  =  "Prince Edward Island", 
                         "Yukon Territory" =  "Yukon Territory",         
                         "Manitoba"  =  "Manitoba",           
                         "Ontario" =  "Ontario",                
                         "Nunavut" =  "Nunavut",                 
                         "Northwest Territories" =  "Northwest Territories",  
                         "Cuba"  = "Cuba" ,               
                         "Bahamas"  = "Bahamas"  ),
                       selected=c("NorthEast","MidAtlantic","SouthEast",
                                  "MidWest", "SouthernPlains","GreatPlains", 
                                  "RockyMountains", "SouthWest", "NorthWest"),
                       inline = FALSE),
    
    h5("Created by:"),
    tags$a("Steven Brey | Ph.D. Student", 
           href="http://atmos.colostate.edu/~sjbrey/"),
    br(),
    tags$a("Source code", 
            href="https://github.com/stevenjoelbrey/smokeWheel"),
    h5(textOutput("counter"))
    
  ),
  
  # Show a table summarizing the values entered
  mainPanel(
    
    #img(src = "regionMap.pdf", height = 170, width = 200, align="right"),
    
    checkboxGroupInput("years", "Years to include in June-Sept climatology:",
                       c("2007" = "2007",                 
                         "2008" = "2008",              
                         "2009" =  "2009",              
                         "2010" =  "2010",
                         "2011" =  "2011",
                         "2012" =  "2012",
                         "2013" =  "2013",
                         "2014" =  "2014"
                       ), 
                       selected=c("2007", "2008", "2009", "2010", "2011", 
                                  "2012", "2013", "2014"),
                       inline = TRUE),
    
    plotOutput("smokeTransport", width="750px", height="750px")

    # TODO: Add a figure that plots the slected regions with the color
    # TODO: that matches the arrows. This will be the legend. 
    
  )
))
