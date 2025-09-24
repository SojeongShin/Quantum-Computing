function ret = fact(n)
    if n == 0
        ret = 1;
    else 
        ret = n * fact(n-1);
    end
end
