function [ img ] = pyrReconstruct( pyr )

for p = length(pyr)-1:-1:1
	pyr{p} = pyr{p}+pyr_expand(pyr{p+1});
end
img = pyr{1};

end

