function K = colortransfer(I, J)
% This function will performs color transfer 

% Transform from RGB to Lab color space
SImgLAB = rgb2lab(I);
TImgLAB = rgb2lab(J);


%Extract L, A and B from LAB color space

SImgL = SImgLAB(:,:,1);
SImgA = SImgLAB(:,:,2);
SImgB = SImgLAB(:,:,3);


TImgL = TImgLAB(:,:,1);
TImgA = TImgLAB(:,:,2);
TImgB = TImgLAB(:,:,3);

%Get mean value for each channel

meanSL = mean2(SImgL);
meanSA = mean2(SImgA);
meanSB = mean2(SImgB);

%Subtract mean from data points

noMeanSL = SImgL - meanSL;
noMeanSA = SImgA - meanSA;
noMeanSB = SImgB - meanSB;

%Calculate std deviation

stdLS = std2(SImgL);
stdAS = std2(SImgA);
stdBS = std2(SImgB);

stdLT = std2(TImgL);
stdAT = std2(TImgA);
stdBT = std2(TImgB);

%Scale values
LScaled = noMeanSL * stdLT/stdLS;
AScaled = noMeanSA * stdAT/stdAS;
BScaled = noMeanSB * stdBT/stdBS;

%Re-Add the averages computed by the photograph.
LScaled = LScaled + meanSL;
AScaled = AScaled + meanSA;
BScaled = BScaled + meanSB;

%Combine everything and covert back to RGB!
K = cat(3,LScaled,AScaled,BScaled);
K = lab2rgb(K);
end

