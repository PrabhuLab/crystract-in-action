export_publication_figure <- function(plot, path, width, height) {
  ggplot2::ggsave(paste0(path,".png"),plot,width=width,height=height,dpi=600,bg="white",limitsize=FALSE)
  ggplot2::ggsave(paste0(path,".svg"),plot,width=width,height=height,device=svglite::svglite,bg="white",limitsize=FALSE)
  stopifnot(file.exists(paste0(path,".png")),file.exists(paste0(path,".svg")))
}

export_material_publication_figure <- function(plot, output_dir) {
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  labels <- function(x) gsub("_on_", " on ", x, fixed=TRUE)
  figure <- plot + ggplot2::labs(title=NULL,color="Framework Wyckoff sites",shape="Framework Wyckoff sites") +
    ggplot2::scale_color_discrete(labels=labels) +
    ggplot2::scale_shape_manual(values=c(16,17,15,3,4,8,0,1,2,5),labels=labels) +
    ggplot2::theme_bw(base_size=11) +
    ggplot2::theme(legend.position="bottom",legend.text=ggplot2::element_text(size=8),
      legend.title=ggplot2::element_text(size=9),plot.subtitle=ggplot2::element_text(size=10)) +
    ggplot2::guides(color=ggplot2::guide_legend(ncol=2),shape=ggplot2::guide_legend(ncol=2))
  export_publication_figure(figure,file.path(output_dir,"Figure2"),6.2,5.7)
  data.table::fwrite(plot$data,file.path(output_dir,"Figure2_data.csv"))
}

export_mineral_publication_figures <- function(plots, output_dir) {
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  style <- ggplot2::theme_minimal(base_size=11) + ggplot2::theme(
    axis.text=ggplot2::element_text(size=9),legend.text=ggplot2::element_text(size=8),
    legend.title=ggplot2::element_text(size=9),plot.title=ggplot2::element_text(size=11),
    plot.subtitle=ggplot2::element_text(size=9),strip.text=ggplot2::element_text(size=10))
  wrap_title <- function(text) paste(strwrap(text,width=52),collapse="\n")
  f3 <- plots$p83 + style + ggplot2::labs(title=wrap_title(plots$p83$labels$title),x="Occupancy-weighted coordination number")
  f4a <- plots$p91 + style + ggplot2::labs(title=wrap_title(paste("(a)",plots$p91$labels$title)),x=NULL) +
    ggplot2::theme(axis.text.x=ggplot2::element_text(size=8,angle=90,vjust=.5,hjust=1))
  f4b <- plots$p92 + style + ggplot2::labs(title=wrap_title(paste("(b)",plots$p92$labels$title))) +
    ggplot2::theme(axis.text.x=ggplot2::element_text(size=8,angle=90,vjust=.5,hjust=1))
  f4a <- f4a + ggplot2::guides(size=ggplot2::guide_legend(ncol=2))
  f4b <- f4b + ggplot2::guides(size=ggplot2::guide_legend(ncol=2))
  f4 <- gridExtra::arrangeGrob(f4a,f4b,ncol=1)
  f5 <- plots$p94 + style + ggplot2::labs(title=wrap_title(plots$p94$labels$title),subtitle="n = distinct CIF records; subsets may overlap") +
    ggplot2::theme(axis.text.x=ggplot2::element_text(size=8,angle=90,vjust=.5,hjust=1),
      legend.position="bottom",legend.box="vertical") +
    ggplot2::guides(size=ggplot2::guide_legend(nrow=1),color=ggplot2::guide_colorbar(direction="horizontal"))
  f6 <- plots$p11 + style + ggplot2::labs(title=wrap_title(plots$p11$labels$title),subtitle=wrap_title(plots$p11$labels$subtitle)) +
    ggplot2::theme(legend.position="bottom",legend.text=ggplot2::element_text(size=8),
      axis.text.x=ggplot2::element_text(size=8)) + ggplot2::guides(color=ggplot2::guide_legend(ncol=3))
  export_publication_figure(f3,file.path(output_dir,"Figure3"),6.2,7.5)
  export_publication_figure(f4,file.path(output_dir,"Figure4"),6.2,7.5)
  export_publication_figure(f5,file.path(output_dir,"Figure5"),6.2,5.7)
  export_publication_figure(f6,file.path(output_dir,"Figure6"),6.2,5.5)
  for (name in names(plots)) data.table::fwrite(plots[[name]]$data,file.path(output_dir,paste0(name,"_data.csv")))
}
