function [iShift,cImage]=regFrame(uImage,ffTemplate)
    [iShift,cImage]=dftregistration(ffTemplate,fft2(uImage),100);
    cImage=abs(ifft2(cImage));
end