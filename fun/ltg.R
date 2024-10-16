ltg<- function(df){
  df |> 
    ggplot()+
    geom_point(aes(latitude, total, color=total))+
    
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5))+
    stat_summary(aes(latitude, total, color=total), fun.y=mean, geom="line", colour="black")+
    
    
    #theme(legend.position = "none")+
    theme(legend.title = element_text(colour="black", size=10, face="bold",angle = 90),
          legend.title.align = 0.5)+
    scale_x_continuous(breaks= c(-60,-30,0,30,60),
                       labels=c("60°S","30°S","0","30°N","60°N"),
                       limits=c(-80,90) )+
    coord_flip()+
    theme_Publication()+
    
    scale_color_gradientn(colours = my.colors,#RColorBrewer::brewer.pal(11, 'Spectral')[11:1],
                          guide = guide_colourbar(
                            title.position = "left",  barwidth=0.5,barheight=10,ticks=TRUE,
                            nbin = 10))+
    theme(legend.position = "right",
          legend.key.size= unit(0.2, "cm"),
          legend.spacing = unit(0, "cm"),
          legend.title = element_text(face="bold",angle = 90),
          legend.title.align = 0.5)
}