function fish_right_prompt --description 'Display right prompt'
    set PROMPT (set_color -b 585858)(set_color bbbbbb)" "(date +%H:%M:%S)" "
    builtin echo -ns $PROMPT(set_color normal)
end
