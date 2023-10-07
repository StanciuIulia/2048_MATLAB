function Start_2048_Game
    prompt = {'\fontsize{10} How big do you want your gameplay to be? Recommended version = 4.'};
    dlgtitle = 'Welcome to 2048 game in MATLAB';
    dims = [1 80];
    definput = {'4'};
    options.WindowStyle='normal';
    options.Interpreter = 'tex'; 
    answer = inputdlg(prompt,dlgtitle,dims,definput, options);
    
    game = FinalProject_2048Game(str2num(answer{1}));
end

