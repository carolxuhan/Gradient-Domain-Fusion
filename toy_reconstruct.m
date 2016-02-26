function im_out = toy_reconstruct(im)

[H, W, C] = size(im);
im2var = zeros(H, W);
im2var(1:H*W) = 1:H*W;

A = sparse([], [], []);
b = [];

e = 1;
for y = 1:H
    for x = 1:W-1
        A(e, im2var(y, x)) = 1;
        A(e, im2var(y, x + 1)) = -1;
        b(e) = im(y, x) - im(y, x + 1);
        e = e + 1;
    end
end

for y = 1:H-1
    for x = 1:W
        A(e, im2var(y, x)) = 1;
        A(e, im2var(y + 1, x)) = -1;
        b(e) = im(y, x) - im(y + 1, x);
        e = e + 1;
    end
end

A(e, im2var(1, 1)) = 1;
b(e) = im(1, 1);

b = b.';
v = A \ b;

im_out = zeros(H, W);
im_out(1:H*W) = v(1:H*W);

