function [] = make_boxplot(practice_vals, game_vals)

x = [practice_vals'; game_vals'];
char1 = 'Practice';
char2 = 'Game    ';

for i = 1:length(x)
    if (i <= length(practice_vals))
        g(i,:) = char1;
    else
        g(i,:) = char2;
    end
end


% get quantiles for the Boxplot
q95=quantile(practice_vals,0.95);
q75=quantile(practice_vals,0.75);
q25=quantile(practice_vals,0.25);

q95=quantile(game_vals,0.95);
q75=quantile(game_vals,0.75);
q25=quantile(game_vals,0.25);

w95=(q95-q75)/(q75-q25);

figure
h = boxplot(x, g);
set(h(1,:),{'Ydata'},num2cell(s(end-1:end,:),1)')
