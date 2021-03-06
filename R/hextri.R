
hexen<-function(center_x,center_y,radii,cols,border=FALSE,asp=1){
	x<-as.vector(t(outer(radii,tri_x)+center_x))
	y<-as.vector(t(outer(radii*asp,tri_y)+center_y))
	polygon(x,y,col=as.vector(t(cols)),border=if(border) NA else as.vector(t(cols)))
	
	invisible(list(x=x,y=y,col=as.vector(t(cols))))
}


 

sainte_lague= function(votes, nseats){
   nparties<-length(votes)
   denominators=2*(1:nseats)-1
   quotients = outer(votes, denominators, "/")
   last = sort(quotients,decreasing=TRUE)[nseats]
   clear<-rowSums(quotients>last)
   borderline<-rowSums(quotients==last)
   borderline[sample(which(borderline>0),sum(borderline)-(nseats-sum(clear)))]<-0
   total<-clear+borderline
   error<- votes- sum(votes)*total/6
   rval<-rep(1:nparties,clear+borderline)
   attr(rval,"error")<-error
   rval
} 


hextri<-function(x,y,class,colours,nbins=10,border=TRUE, diffuse=FALSE,
        style=c("alpha","size"),...){
  style<-match.arg(style)
  if(!diffuse){
  switch(style,
    size=hexclass(x,y,class,colours,nbins=nbins,border=border,...),
    alpha=hexclass1(x,y,class,colours,nbins=nbins,border=border,...)
  )
  } else {
  	switch(style,
    size=hexclass_diffuse(x,y,class,colours,nbins=nbins,border=border,...),
    alpha=hexclass1_diffuse(x,y,class,colours,nbins=nbins,border=border,...)
  )
  }
}

hexclass<-function(x,y,class,colours,nbins=10,border=FALSE,...){
	plot(x,y,type="n",...)
	pin<-par("pin")
	h<-hexbin(x,y,IDs=TRUE,xbins=nbins,shape=pin[2]/pin[1])
	centers<-hcell2xy(h)
    asp<-(diff(h@ybnds)/diff(h@xbnds))/h@shape
	tab<-table(h@cID,class)
	allocations<-apply(tab,1,sainte_lague,6)
	full_radius<-diff(h@xbnds)/h@xbins/sqrt(3)
	radii<-full_radius*sqrt(h@count/max(h@count))
	col_matrix<-matrix(colours[t(allocations)],nrow=ncol(allocations))
	hexen(centers$x,centers$y,radii, col_matrix,border=border,asp=asp)
}


hexclass1<-function(x,y,class,colours,nbins=10,border=FALSE,...){
	plot(x,y,type="n",...)
	pin<-par("pin")
	h<-hexbin(x,y,IDs=TRUE,xbins=nbins,shape=pin[2]/pin[1])
	centers<-hcell2xy(h)
    asp<-(diff(h@ybnds)/diff(h@xbnds))/h@shape
	tab<-table(h@cID,class)
	allocations<-apply(tab,1,sainte_lague,6)
	full_radius<-diff(h@xbnds)/h@xbins/sqrt(3)
	alpha<-h@count/max(h@count)
	all_colours<-colours[t(allocations)]
	rgb<-col2rgb(all_colours)
	alpha_colours<-rgb(rgb[1,],rgb[2,],rgb[3,],255*alpha,max=255)
	col_matrix<-matrix(alpha_colours,nrow=ncol(allocations))
	hexen(centers$x,centers$y,rep(full_radius,length(centers$x)), col_matrix,border=border,asp=asp)
}


hexclass_diffuse<-function(x,y,class,colours,nbins=10,border=FALSE,...){
	plot(x,y,type="n",...)
	pin<-par("pin")
	h<-hexbin(x,y,IDs=TRUE,xbins=nbins,shape=pin[2]/pin[1])
	centers<-hcell2xy(h)
    asp<-(diff(h@ybnds)/diff(h@xbnds))/h@shape
	tab<-table(h@cID,class)
	allocations<-diffuse(h,tab)
	full_radius<-diff(h@xbnds)/h@xbins/sqrt(3)
	radii<-full_radius*sqrt(h@count/max(h@count))
	col_matrix<-matrix(colours[t(allocations)],nrow=ncol(allocations))
	hexen(centers$x,centers$y,radii, col_matrix,border=border,asp=asp)
}


hexclass1_diffuse<-function(x,y,class,colours,nbins=10,border=FALSE,...){
	plot(x,y,type="n",...)
	pin<-par("pin")
	h<-hexbin(x,y,IDs=TRUE,xbins=nbins,shape=pin[2]/pin[1])
	centers<-hcell2xy(h)
    asp<-(diff(h@ybnds)/diff(h@xbnds))/h@shape
	tab<-table(h@cID,class)
	allocations<-diffuse(h,tab)
	full_radius<-diff(h@xbnds)/h@xbins/sqrt(3)
	alpha<-h@count/max(h@count)
	all_colours<-colours[t(allocations)]
	rgb<-col2rgb(all_colours)
	alpha_colours<-rgb(rgb[1,],rgb[2,],rgb[3,],255*alpha,max=255)
	col_matrix<-matrix(alpha_colours,nrow=ncol(allocations))
	hexen(centers$x,centers$y,rep(full_radius,length(centers$x)), col_matrix,border=border,asp=asp)
}

