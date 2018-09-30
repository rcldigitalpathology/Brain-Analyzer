function [Slide] = ReadSlide(XmlFile,SlideId)
% Guy Nir, University of British Columbia, Vancouver, 2017

if (nargin < 2) % find the real slice_id from filename (specimen number)
    kk = find(XmlFile == '/',1,'last')+1; SlideId = XmlFile(kk:(end-4));
    kk = find(SlideId == '-',1,'first')+1; SlideId = SlideId(kk:end);
    kk = length(SlideId);
    while(kk > 0)
        if ~isempty(str2num(SlideId(1:kk)))
            break;
        else
            kk = kk - 1;
        end;
    end
    SlideId = str2num(SlideId(1:kk));
    if isempty(SlideId)
        SlideId = 999; % could not establish slide id
    end
end

% Read XML and convert to structured parameters
XmlStruct = xml2struct(XmlFile);
Slide.SlideName = XmlFile(1:(end-4));
Slide.SlideId = SlideId; % get as input...
try
    Slide.SlideRes = XmlStruct.Annotations.Attributes.MicronsPerPixel * 1e-6 / 100; % full size image resolution in [m/pixel], (should be 0.5040 [um], but it's not!!)
catch
    Slide.SlideRes = 1;
end
if ~isfield(XmlStruct.Annotations, 'Annotation'), annot_num = 0;
else annot_num = length(XmlStruct.Annotations.Annotation); end
if (annot_num == 1), XmlStruct.Annotations.Annotation = num2cell(XmlStruct.Annotations.Annotation); end
Slide.AnnotNum = annot_num;

for annot_indx = 1:annot_num
    Slide.Annot(annot_indx).AnnotName = XmlStruct.Annotations.Annotation{annot_indx}.Attributes.Name; % annonation name
    
    plot_color_hex = str2double(XmlStruct.Annotations.Annotation{annot_indx}.Attributes.LineColor);
    plot_color_hex = dec2hex(plot_color_hex,6); % the color map is given in hexadec, 8bit for each channel, with red and blue "flipped" in order...
    Slide.Annot(annot_indx).AnnotColor = [hex2dec(plot_color_hex(5:6)), hex2dec(plot_color_hex(3:4)), hex2dec(plot_color_hex(1:2))]/255; %  % annonation color as RGB 1x3 vector
    
    if (~isempty(Slide.Annot(annot_indx).AnnotName)) % give classification index by name if available as first priority
        switch lower(Slide.Annot(annot_indx).AnnotName(1))
            case {'s'}
                if (lower(Slide.Annot(annot_indx).AnnotName(2))=='c')
                    Slide.Annot(annot_indx).AnnotClass = 9; % SC = Small Cribriform Subcategory
                    Slide.Annot(annot_indx).AnnotName = 'SC = Small Cribriform Subcategory';
                else
                    Slide.Annot(annot_indx).AnnotClass = 1; % S = Single Separate Glands
                    Slide.Annot(annot_indx).AnnotName = 'S = Single Separate Glands';
                end
            case {'f'}
                Slide.Annot(annot_indx).AnnotClass = 2; % F = Fused small glands
                Slide.Annot(annot_indx).AnnotName = 'F = Fused small glands';
            case {'b'}
                Slide.Annot(annot_indx).AnnotClass = 3; % B = Blue Mucin Containing Separate Glands
                Slide.Annot(annot_indx).AnnotName = 'B = Blue Mucin Containing Separate Glands';
            case {'p'}
                Slide.Annot(annot_indx).AnnotClass = 4; % P = Micropapillary Glands / Those With Slit-like Spaces
                Slide.Annot(annot_indx).AnnotName = 'P = Micropapillary Glands / Those With Slit-like Spaces';
            case {'c'}
                Slide.Annot(annot_indx).AnnotClass = 5; % C = Cribriform to Solid Glands (includes glomeruloid)
                Slide.Annot(annot_indx).AnnotName = 'C = Cribriform to Solid Glands (includes glomeruloid)';
            case {'i'}
                Slide.Annot(annot_indx).AnnotClass = 6; % I = Individual Tumor Cells not forming glands
                Slide.Annot(annot_indx).AnnotName = 'I = Individual Tumor Cells not forming glands';
            case {'m'}
                Slide.Annot(annot_indx).AnnotClass = 7; % M = Mucinous Carcinoma (cells float in mucin)
                Slide.Annot(annot_indx).AnnotName = 'M = Mucinous Carcinoma (cells float in mucin)';
            case {'t'}
                Slide.Annot(annot_indx).AnnotClass = 8; % T = True Papillary With Stromal Cores
                Slide.Annot(annot_indx).AnnotName = 'T = True Papillary With Stromal Cores';
            case {'h'}
                Slide.Annot(annot_indx).AnnotClass = 10; % H = High Grade PIN
                Slide.Annot(annot_indx).AnnotName = 'H = High Grade PIN';
            case {'a'}
                if (lower(Slide.Annot(annot_indx).AnnotName(2))=='i')
                    Slide.Annot(annot_indx).AnnotClass = 12; % AI = Atrophy with Inflamm
                    Slide.Annot(annot_indx).AnnotName = 'AI = Atrophy with Inflamm';
                else
                    Slide.Annot(annot_indx).AnnotClass = 11; % A = Atrophy w/o Inflamm
                    Slide.Annot(annot_indx).AnnotName = 'A = Atrophy w/o Inflamm';
                end
            otherwise
                Slide.Annot(annot_indx).AnnotClass = 99;
                Slide.Annot(annot_indx).AnnotName = 'N/A';
        end % switch name
    else
        Slide.Annot(annot_indx).AnnotClass = 99;
        Slide.Annot(annot_indx).AnnotName = 'N/A';
    end % if
    
    if (Slide.Annot(annot_indx).AnnotClass == 99) % give classification index by color as second priority
        switch (plot_color_hex)
            case {'00FF00'}
                Slide.Annot(annot_indx).AnnotClass = 1; % S = Single Separate Glands
                Slide.Annot(annot_indx).AnnotName = 'S = Single Separate Glands';
            case {'00FFFF'}
                Slide.Annot(annot_indx).AnnotClass = 2; % F = Fused small glands
                Slide.Annot(annot_indx).AnnotName = 'F = Fused small glands';
            case {'0000FF'}
                Slide.Annot(annot_indx).AnnotClass = 3; % B = Blue Mucin Containing Separate Glands
                Slide.Annot(annot_indx).AnnotName = 'B = Blue Mucin Containing Separate Glands';
            case {'008000'}
                Slide.Annot(annot_indx).AnnotClass = 4; % P = Micropapillary Glands / Those With Slit-like Spaces
                Slide.Annot(annot_indx).AnnotName = 'P = Micropapillary Glands / Those With Slit-like Spaces';
            case {'FF00FF'}
                Slide.Annot(annot_indx).AnnotClass = 5; % C = Cribriform to Solid Glands (includes glomeruloid)
                Slide.Annot(annot_indx).AnnotName = 'C = Cribriform to Solid Glands (includes glomeruloid)';
            case {'FFFF80'}
                Slide.Annot(annot_indx).AnnotClass = 6; % I = Individual Tumor Cells not forming glands
                Slide.Annot(annot_indx).AnnotName = 'I = Individual Tumor Cells not forming glands';
            case {'FF0000'}
                Slide.Annot(annot_indx).AnnotClass = 7; % M = Mucinous Carcinoma (cells float in mucin)
                Slide.Annot(annot_indx).AnnotName = 'M = Mucinous Carcinoma (cells float in mucin)';
            case {'000000'}
                Slide.Annot(annot_indx).AnnotClass = 8; % T = True Papillary With Stromal Cores
                Slide.Annot(annot_indx).AnnotName = 'T = True Papillary With Stromal Cores';
            case {'808080'}
                Slide.Annot(annot_indx).AnnotClass = 9; % SC = Small Cribriform Subcategory
                Slide.Annot(annot_indx).AnnotName = 'SC = Small Cribriform Subcategory';
            case {'FFFFFF'}
                Slide.Annot(annot_indx).AnnotClass = 10; % H = High Grade PIN
                Slide.Annot(annot_indx).AnnotName = 'H = High Grade PIN';
            case {'0080FF'}
                Slide.Annot(annot_indx).AnnotClass = 11; % A = Atrophy w/o Inflamm
                Slide.Annot(annot_indx).AnnotName = 'A = Atrophy w/o Inflamm';
            case {'004080'}
                Slide.Annot(annot_indx).AnnotClass = 12; % AI = Atrophy with Inflamm
                Slide.Annot(annot_indx).AnnotName = 'AI = Atrophy with Inflamm';
            otherwise
                Slide.Annot(annot_indx).AnnotClass = 99;
                Slide.Annot(annot_indx).AnnotName = 'N/A';
        end % switch color
    end % if
    
    if ~isfield(XmlStruct.Annotations.Annotation{annot_indx}.Regions, 'Region'), regn_num = 0;
    else regn_num = length(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region); end
    if (regn_num == 1), XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region = num2cell(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region); end
    Slide.Annot(annot_indx).RegnNum = regn_num;
    
    for regn_indx = 1:regn_num
        Slide.Annot(annot_indx).Regn(regn_indx).RegnArea = str2double(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Attributes.Area); % in full size pixels, multiply by full_img_res^2 to get in [m^2].
        Slide.Annot(annot_indx).Regn(regn_indx).RegnLength = str2double(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Attributes.Length); % in full size pixels, multiply by full_img_res to get in [m].
        
        if ~isfield(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Vertices, 'Vertex'), vert_num = 0;
        else vert_num = length(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Vertices.Vertex); end
        if (vert_num == 1), XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Vertices.Vertex = num2cell(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Vertices.Vertex); end
        
        Slide.Annot(annot_indx).Regn(regn_indx).RegnVertXY = zeros(vert_num,2); % allocate variables
        for vert_indx = 1:vert_num
            Slide.Annot(annot_indx).Regn(regn_indx).RegnVertXY(vert_indx,1) = str2double(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Vertices.Vertex{vert_indx}.Attributes.X);
            Slide.Annot(annot_indx).Regn(regn_indx).RegnVertXY(vert_indx,2) = str2double(XmlStruct.Annotations.Annotation{annot_indx}.Regions.Region{regn_indx}.Vertices.Vertex{vert_indx}.Attributes.Y);
        end % for vert_indx
    end % for regn_indx
end % for annot_indx
end
