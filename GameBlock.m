classdef GameBlock < handle
    % GameBlock  Class for drawing the game block

    properties (SetAccess = protected)
        Position
        Txt
        Width
        Height
    end
    
    properties (Dependent)
        RectanglePosition
    end
    
    properties (Access = protected)
        hBox
        hText
    end
    
    methods
        function obj = GameBlock(x, y, txt, wd, ht, hAx, cs)
            
            if nargin == 0
                return;
            end
            
            error(nargchk(6,7,nargin,'struct')) 
            
            if nargin == 6
                hAx = gca;
            end
            
            validateattributes(x, {'numeric'}, {'vector'}, mfilename, 'X');
            validateattributes(y, {'numeric'}, {'vector', 'size', size(x)}, mfilename, 'Y');
            validateattributes(txt, {'cell'}, {'vector', 'size', size(x)}, mfilename, 'TXT');
            validateattributes(wd, {'numeric'}, {'scalar', 'positive'}, mfilename, 'WD');
            validateattributes(ht, {'numeric'}, {'scalar', 'positive'}, mfilename, 'HT');
            validateattributes(hAx, {'numeric','matlab.graphics.axis.Axes'}, {'scalar'}, mfilename, 'HAX');
            
            if ~ishandle(hAx)
                error('HAX must be a valid handle to an axes');
            end
            
            obj(length(x)) = GameBlock;
            
            for id = 1:length(x)
                obj(id).Position = [x(id), y(id)];
                obj(id).Width = wd;
                obj(id).Height = ht;
                obj(id).Txt = txt{id};
                obj(id).hBox = rectangle(...
                    'Parent', hAx, ...
                    'Position', obj(id).RectanglePosition, ...
                    'Curvature', [.1 .1], ...
                    'EdgeColor', 'none', ...
                    'FaceColor', [205 192 180]/255);
                obj(id).hText = text(x(id), y(id), txt{id}, ...
                    'Parent', hAx, ...
                    'VerticalAlignment', 'middle', ...
                    'HorizontalAlignment', 'center', ...
                    'FontName', 'Calibri', ...
                    'FontWeight', 'bold', ...
                    'FontUnits', 'Pixels', ...
                    'FontSize', 48);
            end
            
            updateColors(obj, cs)
            
        end
%---------------------------------------------------------------------------------------------------------
        function val = get.RectanglePosition(obj)
            val = [obj.Position-[obj.Width/2, obj.Height/2], obj.Width, obj.Height];
        end
%---------------------------------------------------------------------------------------------------------
        function updateColors(obj, cs)
            txt = get([obj.hText], 'String');
            
            fontsizeTable = [48 44 32 28 26 24];
            fontsize = 28*ones(length(obj),1);
            
            bgDarkColors =  [0 0 0;...      % black - background dark
                            128 128 128;... % grey
                            205 220 57;...  % lime green
                            139 195 74;...  % light green
                            76 175 80;...   % green
                            0 150 136;...   % teal
                            0 188 212;...   % cyan
                            3 169 244;...   % light blue
                            33 150 243;...  % blue
                            63 81 181;...   % indigo
                            103 58 183;...  % deep purple
                            156 39 176;...  % purple
                            232 30 99;...   % pink
                            232 30 99;...   % pink
                            232 30 99;...   % pink
                            244 67 54;...   % red
                            255 87 34]/255; % deep orange
            
            fgDarkColors = [0 0 0;...       % black
                           0 0 0;...
                           0 0 0]/255;
                        
            bgLightColors = [190 174 157;...    % background light 
                            205 193 181;...     % background '0'
                            239 228 224;...     % background '2'
                            239 223 196;...     % background '4'
                            239 178 123;...     % bg '8'
                            247 151 99;...      % bg '16'
                            248 128 100;...     % bg '32'
                            246 93 59;...       % bg '64'
                            238 205 116;...     % bg '128'
                            240 202 99;...      % bg '256'
                            238 198 82;...      % bg '512'
                            240 198 67;...      % bg '1024'
                            239 194 50;...      % bg '2048'
                            109 201 17;...      % bg '4096'
                            99 190 7;...        % bg '8192'
                            80 172 0;...        % bg '16384', '32768', '65536'
                            59 110 231]/255;    % bg '131072', '262144', '524288'
                        
           fgLightColors = [255 255 255;...      % white
                          120 108 99;...        % dark color for 2 and 4
                          248 244 240]/255;     % bright color for numbers >=8
                      
            if cs
                bgColors = bgDarkColors;
                fgColors = fgDarkColors;
            else 
                bgColors = bgLightColors;
                fgColors = fgLightColors;
            end
            
            % set background color
            bgcolors = repmat(bgColors(1,:), length(obj), 1); % black
            % set foreground color
            fgcolors = repmat(fgColors(1,:), length(obj), 1); % black
            
            % set colors for empty tiles
            ii = strcmp('', txt);
            bgcolors(ii, :) = repmat(bgColors(2,:), nnz(ii), 1);
            % no foreground color
            % fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '2' tiles
            ii = strcmp('2', txt);
            bgcolors(ii, :) = repmat(bgColors(3,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(2,:), nnz(ii), 1); 
            fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '4' tiles
            ii = strcmp('4', txt);
            bgcolors(ii, :) = repmat(bgColors(4,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(2,:), nnz(ii), 1); 
            fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '8' tiles
            ii = strcmp('8', txt);
            bgcolors(ii, :) = repmat(bgColors(5,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1); 
            fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '16' tiles
            ii = strcmp('16', txt);
            bgcolors(ii, :) = repmat(bgColors(6,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1); 
            fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '32' tiles
            ii = strcmp('32', txt);
            bgcolors(ii, :) = repmat(bgColors(7,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1); 
            fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '64' tiles
            ii = strcmp('64', txt);
            bgcolors(ii, :) = repmat(bgColors(8,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1); 
            fontsize(ii) = fontsizeTable(1);
            
            % set colors folt size for '128' tiles
            ii = strcmp('128', txt);
            bgcolors(ii, :) = repmat(bgColors(9,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(2);
            
            % set colors folt size for '256' tiles
            ii = strcmp('256', txt);
            bgcolors(ii, :) = repmat(bgColors(10,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(2);
            
            % set colors folt size for '512' tiles
            ii = strcmp('512', txt);
            bgcolors(ii, :) = repmat(bgColors(11,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(2);
            
            % set colors folt size for '1024' tiles
            ii = strcmp('1024', txt);
            bgcolors(ii, :) = repmat(bgColors(12,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(4);
            
            % set colors folt size for '2048' tiles
            ii = strcmp('2048', txt);
            bgcolors(ii, :) = repmat(bgColors(13,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(4);
            
            % set colors folt size for '4096' tiles
            ii = strcmp('4096', txt);
            bgcolors(ii, :) = repmat(bgColors(14,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(4);
            
            % set colors folt size for '8192' tiles
            ii = strcmp('8192', txt);
            bgcolors(ii, :) = repmat(bgColors(15,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(4);
            
            % set colors folt size for '16384', '32768', '65536' tiles
            ii = ismember(txt, {'16384', '32768', '65536'});
            bgcolors(ii, :) = repmat(bgColors(16,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(5);
            
            % set colors folt size for '131072', '262144', '524288' tiles
            ii = ismember(txt, {'131072', '262144', '524288'});
            bgcolors(ii, :) = repmat(bgColors(17,:), nnz(ii), 1); 
            fgcolors(ii, :) = repmat(fgColors(3,:), nnz(ii), 1);
            fontsize(ii) = fontsizeTable(6);
                                    
            set([obj.hBox], {'FaceColor'}, num2cell(bgcolors,2));
            set([obj.hText], {'Color','FontSize'}, ...
                [num2cell(fgcolors,2), num2cell(fontsize)]);
            
        end
%---------------------------------------------------------------------------------------------------------
        function set(obj, pos, txt)
            if ~isempty(pos) && ~isempty(txt)
                set([obj.hBox], {'Position'}, ...
                    num2cell([pos'-[[obj.Width]/2; [obj.Height]/2]; [obj.Width]; [obj.Height]]',2))
                set([obj.hText], {'String', 'Position'}, ...
                   [txt(:), num2cell([pos, zeros(size(pos,1),1)],2)])
            elseif isempty(pos) && ~isempty(txt)
                set([obj.hText], {'String'}, txt(:))
            elseif ~isempty(pos) && isempty(txt)
                set([obj.hBox], {'Position'}, ...
                    num2cell([pos'-[[obj.Width]/2; [obj.Height]/2]; [obj.Width]; [obj.Height]]',2))
                set([obj.hText], {'Position'}, ...
                   num2cell([pos, zeros(size(pos,1),1)],2))
            else
                error('Either POS or TXT must be non-empty');
            end
        end
%---------------------------------------------------------------------------------------------------------
    end
end