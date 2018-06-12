#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Saisie de tirages de tiques"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
  #splitLayout(
    sidebarPanel(
      fluidRow(
       column(6,dateInput("date","Date", value = Sys.Date())),
       column(6, selectizeInput("collecteurs","collecteurs", choices = "", multiple = TRUE, options=list(placeholder='Choisir un Collecteur :',create = TRUE, onInitialize = I('function() { this.setValue(""); }')))), 
       column(12,hr()),
       column(6,timeInput("time_deb", "Heure Début", seconds = FALSE)),
       column(6,timeInput("time_fin", "Heure Fin", seconds = FALSE)),
       hr(),
       column(6,actionButton("to_current_time_caractdeb", "Heure de début")),
       column(6,actionButton("to_current_time_caractfin", "Heure de fin")),
       column(12,hr()),
       column(6,selectInput("site",
                   "site",
                   choices = NULL)),
       column(6,selectInput("transect",
                            "Transect",
                            choices = NULL)),
       column(12,hr()),
       column(6,sliderInput("nymph","Nymphes",0,100,0,1)),
       column(6,sliderInput("male","Mâles",0,10,0,1)),
       column(6,sliderInput("femelles","Femelles",0,10,0,1)),
       column(4,actionButton("submit","Soumettre"),offset = 2),
       column(4,actionButton("supress","Supprimer"),offset = 2),
       column(12,hr()),
       column(6,selectInput("larves","Larves",choices = NULL)),
       column(6,textInput("autre","Autre"))

    )),
    
    # Show a plot of the generated distribution
    mainPanel(
      DT::dataTableOutput("display")
    )
  )
))
