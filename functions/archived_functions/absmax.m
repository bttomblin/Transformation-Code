function signed_absolute_max = absmax(V)

pos_max = max(V);
neg_max = min(V);

if(pos_max >= abs(neg_max))
    signed_absolute_max = pos_max;
else
    signed_absolute_max = neg_max;
end
