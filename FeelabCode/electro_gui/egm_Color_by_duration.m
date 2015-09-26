function handles = egm_Color_by_duration(handles)

mindur = 0.007;
maxdur = 0.56386031746032;

xl = get(handles.axes_Sonogram,'xlim');
yl = get(handles.axes_Sonogram,'ylim');
fig = figure;
set(fig,'units','inches');
pos = get(fig,'position');
pos(3) = handles.ExportSonogramWidth*(xl(2)-xl(1));
pos(4) = handles.ExportSonogramHeight;
set(fig,'position',pos);
subplot('position',[0 0 1 1]);
hold on

filenum = str2num(get(handles.edit_FileNumber,'string'));
seg = handles.SegmentTimes{filenum}/handles.fs;

ch = findobj('parent',handles.axes_Sonogram,'type','image');
for c = 1:length(ch)
    x = get(ch(c),'xdata');
    y = get(ch(c),'ydata');

    d = get(ch(c),'cdata');
    cl = get(handles.axes_Sonogram,'clim');
    d = d-cl(1);
    d = d/(cl(2)-cl(1));
    d(find(d<0))=0;
    d(find(d>1))=1;
    
    s = zeros(size(d));
    h = zeros(size(d));
    v = zeros(size(d));
    for j = 1:size(seg,1)
        h(:,find(x>=seg(j,1) & x<=seg(j,2))) = (seg(j,2)-seg(j,1)-mindur)/(maxdur-mindur)*6/7;
        s(:,find(x>=seg(j,1) & x<=seg(j,2))) = 1;
        v(:,find(x>=seg(j,1) & x<=seg(j,2))) = d(:,find(x>=seg(j,1) & x<=seg(j,2)));
    end
    h(find(h<0))=0;
    h(find(h>6/7))=6/7;
    m = hsv2rgb(cat(3,h,s,v));

    f = find(x>=xl(1) & x<=xl(2));
    g = find(y>=yl(1) & y<=yl(2));
    imagesc(x(f),y(g),m(g,f,:));
end

axis tight;
axis off
print('-dmeta',['-f' num2str(fig)],['-r' num2str(handles.ExportSonogramResolution)]);