function [grayscale] = color2gray(image)
%color2gray Convert RGB images to grayscale without loss of contrast

    image = rgb2hsv(image);
    
    [height, width, ~] = size(image);
    pixelIndices = zeros(height, width); 
    pixelIndices(1:height*width) = 1:height*width;
    
    A = sparse(height*width*4, height*width);
    b = zeros(height*width*4, 1);
    
    e = 0;
    
    for x = 1:width
        for y = 1:height
            % Left neighbor
            if x-1 > 0
                e = e + 1;
                satGrad = image(y,x,2) - image(y,x-1,2);
                valGrad = image(y,x,3) - image(y,x-1,3);
                if abs(satGrad) > abs(valGrad)
                    strongestGrad = satGrad;
                else
                    strongestGrad = valGrad;
                end
                A(e, pixelIndices(y,x)) = 1;
                A(e, pixelIndices(y,x-1)) = -1;
                b(e) = strongestGrad;
            end
            
            % Right neighbor
            if x+1 <= width
                e = e + 1;
                satGrad = image(y,x,2) - image(y,x+1,2);
                valGrad = image(y,x,3) - image(y,x+1,3);
                if abs(satGrad) > abs(valGrad)
                    strongestGrad = satGrad;
                else
                    strongestGrad = valGrad;
                end
                A(e, pixelIndices(y,x)) = 1;
                A(e, pixelIndices(y,x+1)) = -1;
                b(e) = strongestGrad;
            end
            
            % Top neighbor
            if y-1 > 0
                e = e + 1;
                satGrad = image(y,x,2) - image(y-1,x,2);
                valGrad = image(y,x,3) - image(y-1,x,3);
                if abs(satGrad) > abs(valGrad)
                    strongestGrad = satGrad;
                else
                    strongestGrad = valGrad;
                end
                A(e, pixelIndices(y,x)) = 1;
                A(e, pixelIndices(y-1,x)) = -1;
                b(e) = strongestGrad;
            end
            
            % Bottom neighbor
            if y+1 <= height
                e = e + 1;
                satGrad = image(y,x,2) - image(y+1,x,2);
                valGrad = image(y,x,3) - image(y+1,x,3);
                if abs(satGrad) > abs(valGrad)
                    strongestGrad = satGrad;
                else
                    strongestGrad = valGrad;
                end
                A(e, pixelIndices(y,x)) = 1;
                A(e, pixelIndices(y+1,x)) = -1;
                b(e) = strongestGrad;
            end
        end
    end
    
    grayscale = full(reshape(A \ b, [height, width]));
end