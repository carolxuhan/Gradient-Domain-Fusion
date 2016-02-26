function im_blend = poissonBlend(im_s, mask_s, im_background)
% poissonB = blend(im_s, mask_s, im_background);
% Merges im_s with im_background in accordance with mask_s into im_blend.
% The nature of the boundary conditions is determined by method.

    [bheight, bwidth, bcolor] = size(im_background);
    [~, ~, imcolor] = size(im_s);
    if (imcolor ~= bcolor)
        error('Pictures need use the same color system!');
    end
        
    % For RGB images, process each channel separately.
    if (bcolor == 3)
        s_red = im_s(:,:,1);
        s_green = im_s(:,:,2);
        s_blue = im_s(:,:,3);
        
        bg_red = im_background(:,:,1);
        bg_green = im_background(:,:,2);
        bg_blue = im_background(:,:,3);
        
        %Apply to blending constraints
        [A_red, b_red] = poisson(s_red, mask_s, bg_red);
        [A_green, b_green] = poisson(s_green, mask_s, bg_green);
        [A_blue, b_blue] = poisson(s_blue, mask_s, bg_blue);
        
        %Reshaping 
        red_out = reshape(A_red\b_red, [bheight bwidth]);
        green_out = reshape(A_green\b_green, [bheight bwidth]);    
        blue_out = reshape(A_blue\b_blue, [bheight bwidth]);

        im_blend = cat(3, red_out, green_out, blue_out);
    end

end

function [A,b] = poisson(im_s, mask_s, im_background)
    % Get the appropriate A and b matrices for least-squares problem Ax=b.

    % For future convenience, create a mapping from array to linear indices.
    [bheight, bwidth] = size(im_background);
    im2var = zeros(bheight, bwidth);
    im2var(1:bheight*bwidth) = 1:bheight*bwidth;

    % The resulting A matrix will be extremely sparse. To preserve memory while
    % optimizing speed, we determine the indices and values of nonzero A
    % entries in advance and set them with a single call to sparse().

    % Equations that directly copy background pixels to output pixels.
    A_normal_rows = zeros(1,bheight*bwidth);
    A_normal_cols = zeros(1,bheight*bwidth);
    A_normal_vals = zeros(1,bheight*bwidth);
    b_normal = zeros(1,bheight*bwidth);
    norm_index = 1;

    % Equations corresponding to pixels inside mask_s with a right- or down-
    % neighbor also inside mask_s.
    A_source_rows = zeros(1,2*bheight*bwidth);
    A_source_cols = zeros(1,2*bheight*bwidth);
    A_source_vals = zeros(1,2*bheight*bwidth);
    b_source = zeros(1,bheight*bwidth);
    source_index = 1;

    % Equations corresponding to pixels inside mask_s with a right- or down-
    % neighbor outside mask_s.
    A_border_rows = zeros(1,bheight*bwidth);
    A_border_cols = zeros(1,bheight*bwidth);
    A_border_vals = zeros(1,bheight*bwidth);
    b_border = zeros(1,bheight*bwidth);
    border_index = 1;

    % Equations corresponding to pixels inside mask_s with an up- or a left-
    % neighbor outside mask_s.
    A_outer_rows = zeros(1,bheight*bwidth);
    A_outer_cols = zeros(1,bheight*bwidth);
    A_outer_vals = zeros(1,bheight*bwidth);
    b_outer = zeros(1,bheight*bwidth);
    outer_index = 1;

    for j=1:bwidth
        for i=1:bheight
            % When outside mask_s, final values should be qual to  background values.
            if (~mask_s(i,j))
                A_normal_rows(norm_index) = norm_index;
                A_normal_cols(norm_index) = im2var(i,j);
                A_normal_vals(norm_index) = 1;
                b_normal(norm_index) = im_background(i,j);
                norm_index = norm_index + 1;
                % Check the positive x- and y- neighbors
                if ((j+1 <= bwidth) && mask_s(i,j+1))
                    A_outer_rows(outer_index) = outer_index;
                    A_outer_cols(outer_index) = im2var(i,j+1);
                    A_outer_vals(outer_index) = 1;
                    d = im_s(i,j+1)-im_s(i,j);
                    b_outer(outer_index) = d + im_background(i,j);
                    outer_index = outer_index + 1;
                end
                if ((i+1 <= bheight) && mask_s(i+1,j))
                    A_outer_rows(outer_index) = outer_index;
                    A_outer_cols(outer_index) = im2var(i+1,j);
                    A_outer_vals(outer_index) = 1;
                    d = im_s(i+1,j)-im_s(i,j);
                    b_outer(outer_index) = d + im_background(i,j);
                    outer_index = outer_index + 1;
                end

            % Otherwise, we must differentiate between (inner) border and
            % foreground pixels in both directions.
            else
                % Handle x-gradient
                if (mask_s(i,j+1))
                    t = (source_index + 1) ./ 2;
                    A_source_rows(source_index) = t;
                    A_source_cols(source_index) = im2var(i,j);
                    A_source_vals(source_index) = 1;
                    d = im_s(i,j)-im_s(i,j+1);
                    b_source(t) = d;
                    t = source_index + 1;               
                    A_source_rows(t) = A_source_rows(source_index);
                    A_source_cols(t) = im2var(i,j+1);
                    A_source_vals(t) = -1;
                    source_index = t + 1;
                else
                    A_border_rows(border_index) = border_index;
                    A_border_cols(border_index) = im2var(i,j);
                    A_border_vals(border_index) = 1;
                    d = im_s(i,j)-im_s(i,j+1);
                    b_border(border_index) = d+im_background(i,j+1);
                    border_index = border_index + 1;
                end

                % Handle y-gradient
                if (mask_s(i+1,j))
                    t = (source_index + 1) ./ 2;
                    A_source_rows(source_index) = t;
                    A_source_cols(source_index) = im2var(i,j);
                    A_source_vals(source_index) = 1;
                    d = im_s(i,j)-im_s(i+1,j);
                    b_source(t) = d;
                    t = source_index + 1;
                    A_source_rows(t) = A_source_rows(source_index);
                    A_source_cols(t) = im2var(i+1,j);
                    A_source_vals(t) = -1;
                    source_index = t + 1;
                else
                    A_border_rows(border_index) = border_index;
                    A_border_cols(border_index) = im2var(i,j);
                    A_border_vals(border_index) = 1;
                    d = im_s(i,j)-im_s(i+1,j);
                    b_border(border_index) = d+im_background(i+1,j);
                    border_index = border_index + 1; 
                end
            end
        end
    end

    % Having generously initialized arrays in order to prevent resizing inside
    % memory, we now strip trailing zeros.
    n = norm_index-1;
    A_normal_rows = A_normal_rows(1:n);
    A_normal_cols = A_normal_cols(1:n);
    A_normal_vals = A_normal_vals(1:n);
    A_normal = sparse(A_normal_rows, A_normal_cols, A_normal_vals, ...
        n, bheight*bwidth);
    b_normal = b_normal(1:n);

    s = source_index-1;
    A_source_rows = A_source_rows(1:s);
    A_source_cols = A_source_cols(1:s);
    A_source_vals = A_source_vals(1:s);
    t = s./2;
    A_source = sparse(A_source_rows, A_source_cols, A_source_vals, ...
        t, bheight*bwidth);
    b_source = b_source(1:t);

    bi = border_index-1;
    A_border_rows = A_border_rows(1:bi);
    A_border_cols = A_border_cols(1:bi);
    A_border_vals = A_border_vals(1:bi);
    A_border = sparse(A_border_rows, A_border_cols, A_border_vals, ...
        bi, bheight*bwidth);
    b_border = b_border(1:bi);

    o = outer_index-1;
    A_outer_rows = A_outer_rows(1:o);
    A_outer_cols = A_outer_cols(1:o);
    A_outer_vals = A_outer_vals(1:o);
    A_outer = sparse(A_outer_rows, A_outer_cols, A_outer_vals, ...
        o, bheight*bwidth);
    b_outer = b_outer(1:o);

    A = cat(1,A_normal,A_source,A_border,A_outer);
    b = cat(2,b_normal,b_source,b_border,b_outer);
    b = b';

end
