classdef GamePlay < handle
    
    properties (Access = public)
        Board;
        Size;
        StopNumber;
        Score = 0;
        Moves = 0;
        GameWon = false;
        GameLost = false;
        
        Changed = true;
    end
    
    events
        GameOver
        Win
    end
    
    methods(Access = 'public')
        function obj = GamePlay(Size)
            % the game size is set by the user through "Size" variable
            if nargin == 0
                % set game size to default size => 4*4 board
                obj.Size = 4; 
                % set game stop number to default => 2048
                obj.StopNumber = 2048;
            else
                obj.Size = Size;
            end
            
            % set the board to all zeros
            obj.Board = zeros(obj.Size);
            % set the winning point to the specific number according 
            %to the board size
            obj.StopNumber = 2^(3*obj.Size-1);
            
            % getting a random start index
            start_index = randi(obj.Size^2, 1, 1);
            
            % setting the probability for the randomly generated number 
            %on the board:
            % default 10% for 4 and 90% for 2
            probability = [0.9, 0.1];
            p = 1:2;
            sample_size = 1;
            
            % getting the power of 2 for the strating tile
            power = randsample(p, sample_size, true, probability);
            
            obj.Board(start_index) = 2^power;
            obj = insertRandomBlock(obj);
        end
%---------------------------------------------------------------------------------------------------------
        function show(obj)
            disp(obj.Board);
        end
%---------------------------------------------------------------------------------------------------------
        function obj = insertRandomBlock(obj)
            
            % finding the empty places on the board where the random number 
            % can appear 
            empty_tiles = find(~obj.Board);
            % getting a random index from the array of empty places on theboard
            index = randi(prod(size(empty_tiles)));
            
            % setting the probability for the randomly generated number on 
            % the board:
            % default 10% for 4 and 90% for 2
            probability = [0.9, 0.1];
            p = 1:2;
            sample_size = 1;
            
            % getting the power of 2 for the strating tile
            power = randsample(p, sample_size, true, probability);
            
            obj.Board(empty_tiles(index)) = 2^power;
        end
%---------------------------------------------------------------------------------------------------------
        %get highest value in the game board (used to check win)
        function val = getHighestBlock(obj)
            val = max(max(obj.Board));
        end
%---------------------------------------------------------------------------------------------------------
        % reset game 
        function reset(obj)
            Size_b = size(obj.Board);
            obj.Board = zeros(Size_b);
            obj = insertRandomBlock(obj);
            obj = insertRandomBlock(obj);
            obj.Score = 0;
            obj.Moves = 0;
            obj.GameWon = false;
            obj.GameLost = false;
            obj.StopNumber = 2^(3*obj.Size-1);
            disp(obj)
        end
%---------------------------------------------------------------------------------------------------------
        % check win (highest value == stop value)
        function event = checkWin(obj)
            if (obj.getHighestBlock == obj.StopNumber)
                obj.GameWon = true;
                if nargout
                    event = true;
                else
                    notify(obj, 'Win')
                end
            else
                if nargout
                    obj.GameWon = false;
                    event = false;
                end
            end
        end
%---------------------------------------------------------------------------------------------------------
        % check id the game ended
        function event = checkEndGame(obj)
            copy_obj = GamePlay(obj.Size);
            copy_obj.Board = obj.Board;
            possible_moves = 'LRUD';
            for m = possible_moves
                succes = collapse(copy_obj, m);
                if succes
                    obj.GameLost = false;
                    if nargout
                        event = false;
                    end
                    return
                end
            end
            
            if nargout
                event = true;
            else
                obj.GameLost = true;
                notify(obj, 'GameOver')
            end
        end
%---------------------------------------------------------------------------------------------------------
        % move the tiles and get result board
        function obj = move(obj, direction)
            % check if the user input is correct: left, right, up or down
            if ~any('LRUD' == direction)
                %if the input is not one of the known directions, return to
                %the main play (try a different key)
                return
            end
            
            if (obj.GameLost == false && obj.GameWon == false)
                obj.Changed = collapse(obj, direction);
                if obj.Changed
                    obj.Moves = obj.Moves + 1;
                    checkWin(obj)
                    obj = insertRandomBlock(obj);
                
                end
                
                checkEndGame(obj);
            end
        end
%---------------------------------------------------------------------------------------------------------
        function change_bool = collapse(obj, direction)
            move_change = 0;
            board_size = obj.Size;
            for i = 1:board_size
                switch direction
                    case 'L'
                        % for each row the blocks get merged to the left
                        % change is the indicator that the move on that
                        % row changed something on the board
                        % score represents the addition to the last score made by
                        %that row
                        
                        [vec, score, change] = obj.merge(obj.Board(i,:));
                        obj.Board(i,:) = vec;
                        
                        move_change = move_change + change;
                        obj.Score = obj.Score + score;
                        
                        
                    case 'R'
                        % for each row the blocks get merged to the right
                        % in order to do that, the row is flipped and we use the
                        % function for the left change, then it is flipped again
                        % change is the indicator that the move on that
                        % row changed something on the board
                        % score represents the addition to the last score made by
                        % that row
                        
                        [vec, score, change] = obj.merge(fliplr(obj.Board(i,:)));
                        obj.Board(i,:) = fliplr(vec);
                        
                        move_change = move_change + change;
                        obj.Score = obj.Score + score;
                        
                        
                    case 'U'
                        % for each column the blocks get merged up
                        
                        [vec, score, change] = obj.merge(obj.Board(:,i));
                        obj.Board(:,i) = vec';
                        
                        move_change = move_change + change;
                        obj.Score = obj.Score + score;
                        
                        
                    case 'D'
                        % for each column the blocks get merged down
                        
                        [vec, score, change] = obj.merge(fliplr(obj.Board(:,i)'));
                        obj.Board(:,i) = fliplr(vec);
                        
                        move_change = move_change + change;
                        obj.Score = obj.Score + score;
                        
                    otherwise
                        return;
                        
                end
            end
            
            if(move_change>0)
                change_bool = true;
            else
                change_bool = false;
            end
        end
%---------------------------------------------------------------------------------------------------------
        function [vec, score, change] = merge(~, vec)
            change = 0;
            score = 0;
            
            board_size = numel(vec);
            % find the number of nonzero elements
            N = nnz(vec);

            if(N == 0)
                return
            elseif(N == 1)
                el = find(vec);
                vec(1) = vec(el);
                vec(2:board_size) = zeros(1, board_size-1);
                if(el ~= 1)
                    change = 1;
                end
                return
            end
            
            k = find(vec);
            non_zero_elements = vec(k);
            
            i=1;
            while(i<N)
                if(non_zero_elements(i) == non_zero_elements(i+1))
                    non_zero_elements(i) = 2* non_zero_elements(i+1);
                    score = score + non_zero_elements(i);
                    non_zero_elements(i+1) = 0;
                    i = i+2;
                else
                    i = i+1;
                end
            end
            
            k = find(non_zero_elements);
            nr_el = nnz(k);
            
            if( vec(1:nr_el) == non_zero_elements(k) )
                change = 0;
            else
                change = 1;
            end
            vec = zeros(1, board_size);
            vec(1:nr_el) = non_zero_elements(k);
            
            return 
        end
%---------------------------------------------------------------------------------------------------------
        function disp(obj)
            fprintf('Score: %d\n', max(obj.Score));
            fprintf('Move: %d\n\n', obj.Moves);
            disp(obj.Board)
        end
    end
end

