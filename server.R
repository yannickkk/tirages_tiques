#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

source("connect.R")
###### création d'un identifiant de session sour nommer la sauvegarde #####

id<-format(Sys.time(), "%H%M%d%m%y")

###### préparation du data frame resultats #####
tirages<-rep(NA,9)
names(tirages)<- c("Site","Transect","Date","Heure début","Heure fin","Collecteurs","Nymphes","Mâles","Femelles")

shinyServer(function(input, output, session) {

########## récupération des heures #############
  
  observeEvent(input$to_current_time_caractdeb, {
    updateTimeInput(session, "time_deb", value = Sys.time())
  })

  observeEvent(input$to_current_time_caractfin, {
    updateTimeInput(session, "time_fin", value = Sys.time())
  })

################# choix site ###################
  
  updateSelectInput(session, "site", choices= c("Gardouch"))

################# collecteurs ###################
  
  updateSelectizeInput(session, "collecteurs", choices= dbGetQuery(con,"SELECT col_nom FROM lu_tables.tr_collecteurs_col;")) 

#################### choix du transect #########
  
  updateSelectInput(session, "transect", choices= append("Transect", dbGetQuery(con, "select tra_transect_name from lu_tables.tr_transects_tra order by tra_id")))

#################### choix des larves  #########
  
  updateSelectInput(session, "larves", choices= append("larves", dbGetQuery(con, "select not_notation from lu_tables.tr_notaticks_not order by not_id")), selected = "pas de larves")
  
############ add output inside HTML and csv  #####  
  
    observeEvent(input$submit, {
    new_tirage<- c(input$site, input$transect, as.character(input$date), strftime(as.POSIXct(input$time_deb), format="%H:%M:%S"), strftime(as.POSIXct(input$time_fin), format="%H:%M:%S"), paste(input$collecteurs,collapse =", "),input$nymph,input$male, input$femelles, input$larves, input$autre)
    observe({print(input$collecteurs)})
    tirages<<- na.omit(rbind(tirages,new_tirage))
    output$display = DT::renderDT(as.data.frame(tirages,row.names = seq(1:dim(tirages)[1])),server = F)
    write.csv2(tirages, paste0("tirage_",id,".csv"), row.names = FALSE)
    dbSendQuery(con, sprintf("insert into main.t_transects_tick_tti (tti_date, tti_transect_name, tti_tra_id, tti_time_begin_cest,
                                                                   tti_time_end_cest, tti_nymph, tti_male, tti_female, tti_larva,
                                                                   tti_other, tti_collector, tti_remark, tti_insert_timestamp, tti_insert_source,
                                                                   tti_insert_user, tti_update_timestamp) VALUES ('%s','%s','%s','%s', '%s','%s', '%s','%s','%s','%s','%s','%s', '%s','%s','%s','%s')",
                           as.character(input$date),input$transect, 110,strftime(as.POSIXct(input$time_deb), format="%H:%M:%S"), strftime(as.POSIXct(input$time_fin), format="%H:%M:%S"),input$nymph,input$male, input$femelles, input$larves, input$autre
                           , paste(input$collecteurs,collapse =", "), 'tti_remark', sub(" CEST","",Sys.time()), 'field', 'ychaval', sub(" CEST","",Sys.time())))

        })     #input$site, n'est pas dans la bdd  tti_id, tti_tra_id, tti_remark
  

  ############ remove output inside HTML and csv  #####  
  
    observeEvent(input$supress , {
   # if (dim(tirages)[1] != 1) {
      tirages<<- tirages[1:dim(tirages)[1]-1,]
      #if (dim(tirages)[1] >= 1) {}
        dbSendQuery(con, "DELETE FROM main.t_transects_tick_tti WHERE tti_id in (select MAX(tti_id) FROM main.t_transects_tick_tti)")
   # if (dim(tirages)[1] == 1) {tirages<<- rep(NA,9)}
      output$display <- DT::renderDT(as.data.frame(tirages, row.names = seq(1:dim(tirages)[1])),server = F)
      write.csv2(tirages, paste0("tirage_",id,".csv"), row.names = FALSE)

          })
  
})




