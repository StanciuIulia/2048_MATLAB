classdef FinalProject_2048Game < handle
    % Final Project Draft Work for MATLAB for Engineering Class 2022-2023
    % Student: Iulia Stanciu
    
    properties (Access = public)
        user_interface
        Game % GamePlay Object
        LastMove % GamePlay Object
        Blocks 
        
        CurrentScore   % Handle of text object displaying current score
        CurrentMoves   % Handle of text object displaying current move number
        
        %Animation = true    % Flag indicating whether to animate
        ColorScheme = true
        
        Toolbar
        ToolbarButtons
        
        hGameOver
        hGameWon
        hMoved
        
        ax
        % Add coordonates for blocks
        xPts
        yPts
    end
    
   events
        Moved
    end

    methods
        function game_obj = FinalProject_2048Game(n)
            % Construct game object
            if nargin == 0
                n = 4;
            end
            game_obj.Game = GamePlay(n);
            game_obj.LastMove =  GamePlay(n);
            game_obj.LastMove.Board = game_obj.Game.Board;
            
            % Add events
            game_obj.hGameOver = event.listener(game_obj.Game, 'GameOver', @game_obj.GameOver);
            game_obj.hGameWon = event.listener(game_obj.Game, 'Win', @game_obj.GameWon);
            
            % Update coordonates for blocks
            game_obj.xPts = repmat(0.5:(n-0.5), n, 1);    % X coordinates of blocks
            game_obj.yPts = repmat(((n-0.5):-1:0.5)', 1, n);  % Y coordinates of blocks
            
            % Get screensize and set parameters for geme figure
            set(0, 'Units', 'Pixels');
            screen = get(0, 'ScreenSize');
            screen_width = screen(3);
            screen_hight = screen(4);
            
            width = 0.3 * screen_width;
            sideMargin = 0.04 * width;
            axWidth = width - 2 * sideMargin;
            axHeight = axWidth;
            
            topMargin = 2 * sideMargin;
            bottomMargin = sideMargin;
            height = axHeight + topMargin + bottomMargin;
            
            boxWidth = axWidth/2 - sideMargin;
            boxHeight = 0.8 * topMargin;

            % Construct game UI
            game_obj.user_interface = figure(...
                'Name', 'Final Project - 2048', ...
                'HandleVisibility', 'off', ...
                'Toolbar', 'none', ...
                'Menu', 'none', ...
                'Color', 'black', ...
                'Units', 'Pixels', ...
                'Position', [(screen_width - width) / 2, (screen_hight - height) / 2, width, height], ...
                'Visible', 'off', ...
                'BusyAction', 'cancel', ...
                'Interruptible', 'off', ...
                'Resize', 'off', ...
                'DockControl', 'off', ...
                'WindowKeyPressFcn', @game_obj.KeyPress);
            
            % Toolbar
            Toolbar = uitoolbar('Parent', game_obj.user_interface);
            
            game_obj.ToolbarButtons(1) = uipushtool(...
                'Parent', Toolbar, ...
                'CData', imresize(imread('restart.png'), [20, 20]), ...
                'TooltipString', 'New Game',...
                'ClickedCallback', @game_obj.newGame);
                  
            game_obj.ToolbarButtons(2) = uitoggletool(...
                'Parent', Toolbar, ...
                'CData', imresize(imread('darkmode.png'), [20, 20]), ...
                'Enable', 'on',...
                'Separator', 'on', ...
                'TooltipString', 'Dark/Light Mode',...
                'ClickedCallback', @game_obj.lightmodeDark);
            
            game_obj.ToolbarButtons(3) = uipushtool(...
                'Parent', Toolbar, ...
                'CData', imresize(imread('undo.jpg'), [20, 20]), ...
                'Separator', 'on', ...
                'TooltipString', 'Undo Last Move',...
                'ClickedCallback', @game_obj.undo);
            
            game_obj.ToolbarButtons(4) = uipushtool(...
                'Parent', Toolbar, ...
                'CData', imresize(imread('addtile.png'), [20, 20]), ...
                'Separator', 'on', ...
                'TooltipString', 'Add New Tile',...
                'ClickedCallback', @game_obj.add_new_tile);
            
            game_obj.ToolbarButtons(5) = uipushtool(...
                'Parent', Toolbar, ...
                'CData', imresize(imread('about_info.png'), [20, 20]), ...
                'Separator', 'on', ...
                'TooltipString', 'About...',...
                'ClickedCallback', @game_obj.aboutGame);
            
            game_obj.ax = axes(...
                'Parent', game_obj.user_interface, ...
                'Units', 'pixels', ...
                'Position', [sideMargin, bottomMargin, axWidth, axHeight], ...
                'Units', 'normalized', ...
                'Visible', 'on', ...
                'Tag', 'mainaxes', ...
                'XTick', [], ...
                'YTick', [], ...
                'XTickLabel', [], ...
                'YTickLabel', [], ...
                'XLim', [0 n], ...
                'YLim', [0 n], ...
                'PlotBoxAspectRatio', [1 1 1], ...
                'Color', 'black');
            
            % Background blocks
            GameBlock(game_obj.xPts(:), game_obj.yPts(:), ...
                repmat({''}, n^2, 1), .9, .9, game_obj.ax, true);
            
            % Game blocks
            game_obj.Blocks = GameBlock(game_obj.xPts(:), game_obj.yPts(:), ...
                repmat({''}, n^2, 1), .9, .9, game_obj.ax, true);
            
            % Score and Moves Display
            game_obj.CurrentScore = uicontrol(...
                'style', 'edit', ...
                'Enable', 'inactive', ...
                'Parent', game_obj.user_interface, ...
                'Units', 'Pixels', ...
                'Position', [sideMargin, height - (topMargin + boxHeight) / 2, boxWidth, boxHeight], ...
                'String', sprintf('Score: %d', game_obj.Game.Score), ...
                'BackGroundColor', get(game_obj.user_interface, 'Color'), ...
                'ForegroundColor','yellow',...
                'FontSize', 14, 'FontWeight', 'bold');
            
            game_obj.CurrentMoves  = uicontrol(...
                'style', 'edit', ...
                'Enable', 'inactive', ...
                'Parent', game_obj.user_interface, ...
                'Units', 'Pixels', ...
                'Position', [ axWidth - boxWidth + sideMargin, height - (topMargin + boxHeight) / 2, boxWidth, boxHeight], ...
                'String', sprintf('Moves: %d', game_obj.Game.Moves), ...
                'BackGroundColor', get(game_obj.user_interface, 'Color'),...
                'ForegroundColor','yellow',...
                'FontSize', 14, 'FontWeight', 'bold');
            
            update_blocks(game_obj)
            set(game_obj.user_interface, 'Visible', 'on');
            
        end
%---------------------------------------------------------------------------------------------------------
        function update_scores(game_obj)
            % updateAllScoresData  Refresh score history table and plot

            set(game_obj.CurrentScore, 'String',...
                sprintf('Score: %d', game_obj.Game.Score));


            set(game_obj.CurrentMoves, 'String',...
                sprintf('Moves: %d', game_obj.Game.Moves));
        end
%---------------------------------------------------------------------------------------------------------
        function update_blocks(obj)
            % updateBlocks  Update the block positions
            
            if ishandle(obj.user_interface)                  
                
                % Display the final block positions
                txt = cellfun(@num2str, num2cell(obj.Game.Board), 'UniformOutput', false);
                disp(txt)
                txt(strcmp(txt, '0')) = {''};
                set(obj.Blocks, [obj.xPts(:), obj.yPts(:)], txt);
                
                updateColors(obj.Blocks, obj.ColorScheme);
                update_scores(obj)
            end
        end
%---------------------------------------------------------------------------------------------------------
        function KeyPress(obj, ~, user_data)
            % KeyPressFcn  Callback to handle key presses
            
            if any(strcmp(user_data.Key, {'uparrow', 'downarrow', 'rightarrow', 'leftarrow'}))
                
                obj.LastMove.Score = obj.Game.Score;
                obj.LastMove.Moves = obj.Game.Moves;
                obj.LastMove.Board = obj.Game.Board;
                
                switch user_data.Key
                    case 'leftarrow'
                        move(obj.Game, 'L');
                        %disp('left')
                    case 'rightarrow'
                        move(obj.Game, 'R');
                        %disp('right')
                    case 'uparrow'
                        move(obj.Game, 'U');
                        %disp('up')
                    case 'downarrow'
                        move(obj.Game, 'D');
                        %disp('down')
                        
                    otherwise
                        return
                end
                update_blocks(obj)
            end
        end
%---------------------------------------------------------------------------------------------------------
        function reset(game_obj)
            game_obj.Game.reset
            game_obj.LastMove =  GamePlay(game_obj.Game.Size);
            game_obj.LastMove.Board = game_obj.Game.Board;
            
            update_blocks(game_obj)
        end
%---------------------------------------------------------------------------------------------------------
        function newGame(game_obj, varargin)
            if nargin > 1
                btn = questdlg('Abandon current game?','New Game', 'Yes', 'No', 'Yes');
                switch btn
                    case 'Yes'
                        % Reset game object
                        game_obj.reset
                    otherwise
                        return
                end
            end
        end
%---------------------------------------------------------------------------------------------------------
        function GameWon(obj, varargin)
            btn = questdlg({'You won! Congratulations!', '', 'Continue playing?'}, 'You Won', 'Continue playing', 'Play new game', 'Quit', 'Continue playing');
            switch btn
                case 'Continue playing'
                    obj.Game.StopNumber = inf;
                    obj.Game.GameWon = false;
                case 'Play new game'
                    obj.reset
                case 'Quit'
                    delete(obj.user_interface)
            end
        end
%---------------------------------------------------------------------------------------------------------
        function GameOver(obj, varargin)
            btn = questdlg({'No more moves', '', 'Play again?'}, 'Game Over', 'Play new game', 'Quit', 'Play new game');
            switch btn
                case 'Play new game'
                    obj.reset
                case 'Quit'
                    delete(obj.user_interface)
            end
        end
%---------------------------------------------------------------------------------------------------------
        function aboutGame(varargin)
            uiwait(msgbox({'Final project for Matlab for Engineering', ...
                '2048 Game (with basic functions and user interface)', ...
                'Student: Stanciu Iulia Cristina', ...
                '', ...
                ['Gameplay: The tiles can be moved using arrow keys.', ...
                'The four possible moves are Up, Down, Left and Right.', ...
                'When two tiles with the same number touch, they merge into one.', ...
                'Reach 2048 (for the basic game) to win the game.']}, ...
                'About', 'Help', 'modal'));
        end
%---------------------------------------------------------------------------------------------------------
        function lightmodeDark(obj, varargin)
            if obj.ColorScheme
                obj.ColorScheme = false;
                updateColors(obj.Blocks, obj.ColorScheme);
                
                set(obj.user_interface, 'Color', 'white');
                set(obj.ax, 'Color', 'white');
                
                set(obj.CurrentScore, 'BackGroundColor', get(obj.user_interface, 'Color'));
                set(obj.CurrentScore, 'ForegroundColor', 'black');
                
                set(obj.CurrentMoves, 'BackGroundColor', get(obj.user_interface, 'Color'));
                set(obj.CurrentMoves, 'ForegroundColor', 'black');
            else 
                obj.ColorScheme = true;
                updateColors(obj.Blocks, obj.ColorScheme);
                
                set(obj.user_interface, 'Color', 'black');
                set(obj.ax, 'Color', 'black');
                
                set(obj.CurrentScore, 'BackGroundColor', get(obj.user_interface, 'Color'));
                set(obj.CurrentScore, 'ForegroundColor', 'yellow');
                
                set(obj.CurrentMoves, 'BackGroundColor', get(obj.user_interface, 'Color'));
                set(obj.CurrentMoves, 'ForegroundColor', 'yellow');
            end
        end
%---------------------------------------------------------------------------------------------------------
        function undo(obj, varargin)
            obj.Game.Score = obj.LastMove.Score;
            obj.Game.Moves = obj.LastMove.Moves;
            obj.Game.Board = obj.LastMove.Board;
            update_blocks(obj)
        end
%---------------------------------------------------------------------------------------------------------
        function add_new_tile(obj, varargin)
            obj.Game = insertRandomBlock(obj.Game);
            checkWin(obj.Game)
            checkEndGame(obj.Game)
            update_blocks(obj)
        end
    end
end

