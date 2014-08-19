;+
; PROCEDURE plot_map_asi_nipr
;
; PURPOSE:
;		Draw NIPR all-sky imager data on the world map
;
;	:Params:
;    asi_vns:   tplot variable to be plotted
;
;	:Keywords:
;	 set_time: set the time (UNIX time) to plot all-sky imager data
;    altitude: set the altitude on which the image data will be mapped.
;              The default value is 110 (km).
;	 colorrange: set the range of values of colorscale
;    glatc: geographical latitude at which a plot region is centered
;    glonc: geographical longitude at which a plot region is centered
;    scale: same as the keyword "scale" of map_set
;    erase: set to erase pre-existing graphics on the plot window.
;    position: set the location of the plot frame in the plot window
;    label: set to label the latitudes and longitudes.
;    stereo: use the stereographic mapping, instead of satellite mapping (default)
;	 mapcharsize: the size of the characters used for the labels.
;    aacgm: set to use the AACGM coordinates
;    mltlabel: set to draw the MLT labels every 2 hour
;    lonlab: a latitude from which (toward the poles) the MLT labels are drawn
;    notimelabel: set to surpress drawing the time label
;	 timelabelpos: set the position of the color scale in the noraml coordinates.
;	 tlcharsize: the size of the characters used for the time label.
;    nocolorscale: set to surpress drawing the color scale 
;    colorscalepos: set the position of the color scale in the noraml 
;                   coordinates. Default: [0.85, 0.1, 0.87, 0.45] 
;    cscharsize: the size of the characters used for the colorscale.
;
; :EXAMPLES:
;   plot_map_asi_nipr, 'nipr_asi_hus_0000'
;   plot_map_asi_nipr, 'nipr_asi_hus_0000', glatc=65., glonc=-15. 
;   
; :AUTHOR:
;    Yoshimasa Tanaka (E-mail: ytanaka@nipr.ac.jp)
;
; :HISTORY:
;    2014/08/03: Created
;
;-
pro plot_map_asi_nipr, asi_vns, set_time=set_time, $
    altitude=altitude, colorrange=colorrange, $
	glatc=glatc, glonc=glonc, $
    scale=scale, erase=erase, position=position, $
	label=label, stereo=stereo, coast=coast, $
	mapcharsize=mapcharsize, $
    coord=coord, mltlabel=mltlabel, lonlab=lonlab, $
    nogrid=nogrid, dlat_grid=dlat_grid, dlon_grid=dlon_grid, $
    color_grid=color_grid, linethick_grid=linethick_grid, $
    notimelabel=notimelabel, timelabelpos=timelabelpos, $
	tlcharsize=tlcharsize, $
    nocolorscale=nocolorscale, colorscalepos=colorscalepos, $
    cscharsize=cscharsize
    
;the tplot var exists?
if total(tnames(asi_vn) eq '') gt 0 then begin
    print, 'not find the tplot variable: '+var
    return
endif
  
;Initialize the 2D plot environment
map2d_init
  
;Set map_set if any map projection is not defined
map2d_set, glatc=glatc, glonc=glonc, $
    scale=scale, erase=erase, position=position, label=label, $
    stereo=stereo, charsize=mapcharsize, $
    coord=coord, set_time=set_time, mltlabel=mltlabel, lonlab=lonlab, $
    nogrid=nogrid, $
    dlat_grid=dlat_grid, dlon_grid=dlon_grid, color_grid=color_grid, $
    linethick_grid=linethick_grid

;Draw a fan plot on map
overlay_map_asi_nipr, asi_vns, set_time=set_time, $
    altitude=altitude, coord=coord, position=position, $
    colorrange=colorrange, $
    notimelabel=notimelabel, timelabelpos=timelabelpos, $
	tlcharsize=tlcharsize, $
    nocolorscale=nocolorscale, colorscalepos=colorscalepos, $
    cscharsize=cscharsize

;Draw the world map
if keyword_set(coast) then begin
    overlay_map_coast, coord=coord, position=position
endif
  
;Draw the color scale on the right in screen
;overlay_color_scale     ;to be developed soon
  
return

end

