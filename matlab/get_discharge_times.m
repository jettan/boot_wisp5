a = diff(x) < 0;
b = diff(a);
indices = [];

len = 0;
for j=1:2498,
    if b(j) == 1
        len = j;
    elseif b(j) == -1
        len = j - len;
        indices = [indices; len];
    end
end

lengths = indices * 2
    