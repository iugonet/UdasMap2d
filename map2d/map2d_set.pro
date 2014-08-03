;+
; PROCEDURE/FUNCTION map2d_set
;
; :DESCRIPTION:
;		A wrapper routine for the IDL original "map_set" enabling some
;		annotations regarding the visualization of 2D data.
;
;	:KEYWORDS:
;    center_glat: geographical latitude at which a plot region is centered.
;    center_glon: geographical longitude at which a plot region is centered.
;                 (both center_glat and center_glon should be given, otherwise ignored)
;    scale: same as the keyword "scale" of map_set
;    erase: aet to erase pre-existing graphics on the plot window.
;    position: gives the position of a plot panel on the plot window as the normal coordinates.
;    label: set to label the latitudes and longitudes.
;    stereo: use the stereographic mapping, instead of satellite mapping (default)
;	 charsize: the size of the characters used for the labels.
;    aacgm: set to use the AACGM coordinates
;    map_time: this is used to calculate MLT when aacgm is set
;    mltlabel: set to draw the MLT labels every 2 hour.
;    lonlab: a latitude from which (toward the poles) the MLT labels are drawn.
;
; :EXAMPLES:
;    map2d_set
;    map2d_set, center_glat=70., center_glon=180., /mltlabel, lonlab=74.
;
; :AUTHOR:
;    Yoshimasa Tanaka (E-mail: ytanaka@nipr.ac.jp)
;
; :HISTORY:
;    2014/07/07: Created
;
;-

PRO map2d_set, center_glat=center_glat, center_glon=center_glon, $
    scale=scale, erase=erase, position=position, label=label, $
    stereo=stereo, charsize=charsize, $
    aacgm=aacgm, map_time=map_time, mltlabel=mltlabel, lonlab=lonlab
    
;----- Initialize the map2d environment -----;
map2d_init
    
;===== Check parameters =====;
;----- center_glat, center_glon -----;
if size(center_glat,/type) eq 0 then center_glat=!map2d.glatc
if size(center_glon,/type) eq 0 then center_glon=!map2d.glonc
center_glon = (center_glon+360.) mod 360.
if center_glon gt 180. then center_glon -= 360.

;----- scale -----;
if ~keyword_set(scale) then scale=!map2d.scale

;----- stereo -----;
if keyword_set(stereo) then begin
    satellite=0
    stereo=1
endif else begin
    satellite=1
    stereo=0
endelse
  
;----- position -----;
pre_pos = !p.position
if keyword_set(position) then begin
    !p.position = position
endif else begin
    nopos = 1
    position = !p.position
endelse
if position[0] ge position[2] or position[1] ge position[3] then begin
    print, '!p.position is not set, temporally use [0,0,1,1]'
    position = [0.,0.,1.,1.]
    !p.position = position
endif

;----- character size -----;
if ~keyword_set(charsize) then charsize=1.0

;----- aacgm -----;
if ~keyword_set(aacgm) then aacgm=!map2d.coord

;----- Resize the canvas size for the position values -----;
if ~keyword_set(nopos) then begin
    scl = (position[2]-position[0]) < (position[3]-position[1])
endif else begin
    scl = 1.
    if !x.window[1]-!x.window[0] gt 0. then $
        scl = (!x.window[1]-!x.window[0]) < (!y.window[1]-!y.window[0])
endelse
scale /= scl

;----- Calculate the rotation angle regarding MLT -----;
;hemisphere flag
if center_glat gt 0 then hemis = 1 else hemis = -1
if keyword_set(aacgm) then begin
    aacgmconvcoord, center_glat, center_glon, 0.1, mlatc, mlonc, err, /to_aacgm
    if ~keyword_set(map_time) then map_time = !map2d.time
    ts = time_struct(map_time) & yrsec = (ts.doy-1)*86400l + long(ts.sod)
    tmltc = aacgmmlt(ts.year, yrsec, mlonc)
    mltc = ( tmltc + 24. ) mod 24.
    mltc_lon = 360./24.* mltc
	if mltc_lon gt 180. then mltc_lon -= 360.
    rot_angle = (-mltc_lon*hemis +360.) mod 360.
    if rot_angle gt 180. then rot_angle -= 360.

    ;rotate oppositely for the s. hemis.
    if hemis lt 0 then begin 
        rot_angle = ( rot_angle + 180. ) mod 360.
        ;rot_angle *= (-1.)
        rot_angle = (rot_angle+360.) mod 360.
        if rot_angle gt 180. then rot_angle -= 360.
    endif
endif else rot_angle = 0.

;calculate the rotation angle of the north dir in a polar plot
;ts = time_struct(time)
;aacgm_conv_coord, 60., 0., 400., mlat,mlon,err, /to_aacgm
;mlt = aacgm_mlt( ts.year, long((ts.doy-1)*86400.+ts.sod), mlon)

;----- Set the lat-lon canvas and draw the continents -----;
if ~keyword_set(aacgm) then begin
    latc=center_glat
    lonc=center_glon
endif else begin
    latc=mlatc
    lonc=mltc_lon
endelse

map_set, latc, lonc, rot_angle, $
    satellite=satellite, stereo=stereo, sat_p=[6.6, 0., 0.], $
    scale=scale, /isotropic, /horizon, noerase=~KEYWORD_SET(erase), $
	label=label, charsize=charsize, latdel=10., londel=15.

;map_grid, latdel=10., londel=15.
  
;    ;Resize the canvas size for the position values
;    scl = (!x.window[1]-!x.window[0]) < (!y.window[1]-!y.window[0])
;    scale /= scl
;    ;Set charsize used for MLT labels and so on
;    charsz = 1.4 * (KEYWORD_SET(clip) ? 50./30. : 1. ) * scl
;    !sdarn.sd_polar.charsize = charsz

if keyword_set(aacgm) and keyword_set(mltlabel) then begin
    ;write the mlt labels
    mlts = 15.*findgen(24) ;[deg]
    lonnames=['00hmlt','','02hmlt','','04hmlt','','06hmlt','','08hmlt','','10hmlt','','12hmlt','', $
        '14hmlt','','16hmlt','','18hmlt','','20hmlt','','22hmlt','']
    if ~keyword_set(lonlab) then lonlab = 77.

    ;calculate the orientation of the mtl labels
    lonlabs0 = replicate(lonlab,n_elements(mlts))
    if hemis eq 1 then lonlabs1 = replicate( (lonlab+10.) < 89.5,n_elements(mlts)) $
    else lonlabs1 = replicate( (lonlab-10.) > (-89.5),n_elements(mlts))
    nrmcord0 = convert_coord(mlts,lonlabs0,/data,/to_device)
    nrmcord1 = convert_coord(mlts,lonlabs1,/data,/to_device)
    ori = transpose( atan( nrmcord1[1,*]-nrmcord0[1,*], nrmcord1[0,*]-nrmcord0[0,*] )*!radeg )
    ori = ( ori + 360. ) mod 360. 

    ;ori = lons + 90 & ori[where(ori gt 180)] -= 360.
    ;idx=where(lons gt 180. ) & lons[idx] -= 360.

    nrmcord0 = convert_coord(mlts,lonlabs0,/data,/to_normal)
    for i=0,n_elements(mlts)-1 do begin
        nrmcord = reform(nrmcord0[*,i])
        pos = [!x.window[0],!y.window[0],!x.window[1],!y.window[1]]
        if nrmcord[0] le pos[0] or nrmcord[0] ge pos[2] or $
            nrmcord[1] le pos[1] or nrmcord[1] ge pos[3] then continue
        xyouts, mlts[i], lonlab, lonnames[i], orientation=ori[i], $
            font=1, charsize=charsize
    endfor

endif
  
;----- Restore the original position setting -----;
!p.position = pre_pos

return
end
